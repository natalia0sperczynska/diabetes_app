# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn, scheduler_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore
import json
import datetime
import os
import hashlib
import requests

initialize_app()
set_global_options(max_instances=5)


# ============= LibreLinkUp API Configuration =============
LIBRE_LINK_UP_VERSION = "4.12.0"
LIBRE_LINK_UP_PRODUCT = "llu.android"

LIBRE_LINK_UP_REGIONS = {
    "eu": "https://api-eu.libreview.io",
    "eu2": "https://api-eu2.libreview.io",
    "us": "https://api-us.libreview.io",
    "de": "https://api-de.libreview.io",
    "fr": "https://api-fr.libreview.io",
    "jp": "https://api-jp.libreview.io",
    "ap": "https://api-ap.libreview.io",
    "au": "https://api-au.libreview.io",
    "ae": "https://api-ae.libreview.io",
    "global": "https://api.libreview.io",
}

LIBRE_TREND_ARROWS = {
    1: "falling_quickly",
    2: "falling",
    3: "stable",
    4: "rising",
    5: "rising_quickly",
}


def get_libre_headers(token: str = None, user_id: str = None) -> dict:
    """Generate headers for LibreLinkUp API requests."""
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Cache-Control": "no-cache",
        "product": LIBRE_LINK_UP_PRODUCT,
        "version": LIBRE_LINK_UP_VERSION,
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"
    if user_id:
        # Account-Id is SHA256 hash of user_id (required since v4.16+)
        account_id = hashlib.sha256(user_id.encode("utf-8")).hexdigest()
        headers["Account-Id"] = account_id
    return headers


def libre_login(email: str, password: str, region: str = "eu") -> dict:
    """Login to LibreLinkUp API and get auth token."""
    base_url = LIBRE_LINK_UP_REGIONS.get(region, LIBRE_LINK_UP_REGIONS["global"])
    
    response = requests.post(
        f"{base_url}/llu/auth/login",
        headers=get_libre_headers(),
        json={"email": email, "password": password},
        timeout=30,
    )
    
    data = response.json()
    
    # Handle region redirect
    if data.get("status") == 2 and data.get("data", {}).get("redirect"):
        new_region = data["data"]["region"]
        new_base_url = LIBRE_LINK_UP_REGIONS.get(new_region, f"https://api-{new_region}.libreview.io")
        response = requests.post(
            f"{new_base_url}/llu/auth/login",
            headers=get_libre_headers(),
            json={"email": email, "password": password},
            timeout=30,
        )
        data = response.json()
        data["_base_url"] = new_base_url
    else:
        data["_base_url"] = base_url
    
    return data


def libre_get_connections(base_url: str, token: str, user_id: str) -> dict:
    """Get patient connections from LibreLinkUp API."""
    response = requests.get(
        f"{base_url}/llu/connections",
        headers=get_libre_headers(token, user_id),
        timeout=30,
    )
    return response.json()


def libre_get_graph_data(base_url: str, token: str, user_id: str, patient_id: str) -> dict:
    """Get glucose graph data for a specific patient."""
    response = requests.get(
        f"{base_url}/llu/connections/{patient_id}/graph",
        headers=get_libre_headers(token, user_id),
        timeout=30,
    )
    return response.json()


@https_fn.on_request()
def get_glucose(req: https_fn.Request) -> https_fn.Response:
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }
    
    if req.method == "OPTIONS":
        return https_fn.Response("", status=204, headers=headers)
    
    try:
        from pydexcom import Dexcom
        
        data = req.get_json() if req.get_json() else {}
        username = data.get('username', '')
        password = data.get('password', '')
        region = data.get('region', 'ous')
        
        if not username or not password:
            return https_fn.Response(
                json.dumps({"error": "Username and password are required"}),
                status=400,
                headers=headers
            )
        
        dexcom = Dexcom(username=username, password=password, region=region)
        bg = dexcom.get_current_glucose_reading()
        
        return https_fn.Response(
            json.dumps({
                "success": True,
                "value": bg.value,
                "trend": str(bg.trend),
                "time": str(bg.datetime)
            }),
            status=200,
            headers=headers
        )
    except Exception as e:
        return https_fn.Response(
            json.dumps({
                "success": False,
                "error": str(e),
                "type": type(e).__name__
            }),
            status=500,
            headers=headers
        )


@scheduler_fn.on_schedule(schedule="every 5 minutes", secrets=["DEXCOM_EMAIL", "DEXCOM_PASSWORD"])
def save_glucose_history(event: scheduler_fn.ScheduledEvent) -> None:
    db = firestore.client()
    USER_EMAIL = os.environ.get("DEXCOM_EMAIL", "")
    DEXCOM_PASS = os.environ.get("DEXCOM_PASSWORD", "")

    print(f"Fetching data for {USER_EMAIL}...")

    try:
        from pydexcom import Dexcom

        dexcom = Dexcom(username=USER_EMAIL, password=DEXCOM_PASS, region='ous')
        bg = dexcom.get_current_glucose_reading()
        
        if not bg:
            print("No data from Dexcom.")
            return

        current_glucose = bg.value
        current_trend = bg.trend_description
        current_time_obj = bg.datetime
        current_time_str = str(current_time_obj)
        doc_id = current_time_str.replace(":", "-").replace(" ", "_").replace(".", "-")

        user_ref = db.collection("Glucose_measurements").document(USER_EMAIL)
        measurement_ref = user_ref.collection("history").document(doc_id)

        measurement_ref.set({
            "Glucose": current_glucose,
            "Trend": current_trend,
            "Time": current_time_str,
            "Timestamp": current_time_obj,
            "SavedAt": firestore.SERVER_TIMESTAMP
        })

        print(f"Saved {current_glucose} mg/dL, trend: {current_trend}")

    except Exception as e:
        print(f"Error: {e}")


@https_fn.on_request()
def get_last_glucose_measurement(req: https_fn.Request) -> https_fn.Response:
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    if req.method == "OPTIONS":
        return https_fn.Response("", status=204, headers=headers)

    data = req.get_json() if req.get_json() else {}
    username = data.get('username', '')
    password = data.get('password', '')
    region = data.get('region', 'ous')

    if not username or not password:
        return https_fn.Response(
            json.dumps({
                "success": False,
                "error": "Username and password are required"
            }),
            status=400,
            headers=headers
        )

    final_glucose = None
    final_trend = None
    final_time = None
    source = "unknown"

    try:
        from pydexcom import Dexcom
        
        dexcom = Dexcom(username=username, password=password, region=region)
        bg = dexcom.get_current_glucose_reading()
        
        if bg:
            final_glucose = bg.value
            final_trend = str(bg.trend)
            final_time = str(bg.datetime)
            source = "live_dexcom"
        else:
            print("No live readings, checking history...")
            readings = dexcom.get_glucose_readings(minutes=1440)
            if readings:
                bg_last = max(readings, key=lambda r: r.datetime)
                final_glucose = bg_last.value
                final_trend = str(bg_last.trend)
                final_time = str(bg_last.datetime)
                source = "history_dexcom_24h"

    except Exception as e:
        print(f"Dexcom error: {e}, trying database fallback...")

    if final_glucose is None:
        try:
            db = firestore.client()
            docs = db.collection("Glucose_measurements")\
                     .document(username)\
                     .collection("history")\
                     .order_by("Timestamp", direction=firestore.Query.DESCENDING)\
                     .limit(1)\
                     .stream()

            for doc in docs:
                doc_data = doc.to_dict()
                final_glucose = doc_data.get('Glucose')
                final_trend = doc_data.get('Trend')
                final_time = doc_data.get('Time')
                source = "firestore_backup"

        except Exception as db_e:
            print(f"Database error: {db_e}")

    if final_glucose is not None:
        return https_fn.Response(
            json.dumps({
                "success": True,
                "value": final_glucose,
                "trend": final_trend,
                "time": final_time,
                "source": source
            }),
            status=200,
            headers=headers
        )
    else:
        return https_fn.Response(
            json.dumps({
                "success": False,
                "error": "No data available from Dexcom (Live/24h) or Database."
            }),
            status=404,
            headers=headers
        )


# ============= LibreLinkUp Functions =============

@https_fn.on_request()
def get_libre_glucose(req: https_fn.Request) -> https_fn.Response:
    """Get current glucose reading from LibreLinkUp API."""
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    if req.method == "OPTIONS":
        return https_fn.Response("", status=204, headers=headers)

    try:
        data = req.get_json() if req.get_json() else {}
        email = data.get("email", "")
        password = data.get("password", "")
        region = data.get("region", "eu")

        if not email or not password:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Email and password are required"}),
                status=400,
                headers=headers,
            )

        # Step 1: Login
        login_response = libre_login(email, password, region)
        
        if login_response.get("status") != 0:
            error_msg = login_response.get("error", {}).get("message", "Login failed")
            return https_fn.Response(
                json.dumps({"success": False, "error": error_msg}),
                status=401,
                headers=headers,
            )

        auth_ticket = login_response.get("data", {}).get("authTicket", {})
        token = auth_ticket.get("token")
        user_id = login_response.get("data", {}).get("user", {}).get("id")
        base_url = login_response.get("_base_url")

        if not token or not user_id:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Failed to get auth token"}),
                status=401,
                headers=headers,
            )

        # Step 2: Get connections
        connections_response = libre_get_connections(base_url, token, user_id)
        
        if connections_response.get("status") != 0:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Failed to get connections"}),
                status=500,
                headers=headers,
            )

        connections = connections_response.get("data", [])
        if not connections:
            return https_fn.Response(
                json.dumps({"success": False, "error": "No patient connections found. Make sure LibreLinkUp sharing is set up."}),
                status=404,
                headers=headers,
            )

        # Get the first connection's glucose data
        connection = connections[0]
        glucose_measurement = connection.get("glucoseMeasurement", {})
        
        if not glucose_measurement:
            return https_fn.Response(
                json.dumps({"success": False, "error": "No glucose measurement available"}),
                status=404,
                headers=headers,
            )

        value = glucose_measurement.get("ValueInMgPerDl") or glucose_measurement.get("Value")
        trend_arrow = glucose_measurement.get("TrendArrow", 3)
        trend = LIBRE_TREND_ARROWS.get(trend_arrow, "unknown")
        timestamp = glucose_measurement.get("Timestamp")
        is_high = glucose_measurement.get("isHigh", False)
        is_low = glucose_measurement.get("isLow", False)

        return https_fn.Response(
            json.dumps({
                "success": True,
                "value": value,
                "trend": trend,
                "trendArrow": trend_arrow,
                "time": timestamp,
                "isHigh": is_high,
                "isLow": is_low,
                "patientName": f"{connection.get('firstName', '')} {connection.get('lastName', '')}".strip(),
                "source": "librelinkup"
            }),
            status=200,
            headers=headers,
        )

    except Exception as e:
        return https_fn.Response(
            json.dumps({
                "success": False,
                "error": str(e),
                "type": type(e).__name__
            }),
            status=500,
            headers=headers,
        )


@https_fn.on_request()
def get_libre_glucose_history(req: https_fn.Request) -> https_fn.Response:
    """Get glucose history (graph data) from LibreLinkUp API."""
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    if req.method == "OPTIONS":
        return https_fn.Response("", status=204, headers=headers)

    try:
        data = req.get_json() if req.get_json() else {}
        email = data.get("email", "")
        password = data.get("password", "")
        region = data.get("region", "eu")

        if not email or not password:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Email and password are required"}),
                status=400,
                headers=headers,
            )

        # Step 1: Login
        login_response = libre_login(email, password, region)
        
        if login_response.get("status") != 0:
            error_msg = login_response.get("error", {}).get("message", "Login failed")
            return https_fn.Response(
                json.dumps({"success": False, "error": error_msg}),
                status=401,
                headers=headers,
            )

        auth_ticket = login_response.get("data", {}).get("authTicket", {})
        token = auth_ticket.get("token")
        user_id = login_response.get("data", {}).get("user", {}).get("id")
        base_url = login_response.get("_base_url")

        if not token or not user_id:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Failed to get auth token"}),
                status=401,
                headers=headers,
            )

        # Step 2: Get connections
        connections_response = libre_get_connections(base_url, token, user_id)
        
        if connections_response.get("status") != 0:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Failed to get connections"}),
                status=500,
                headers=headers,
            )

        connections = connections_response.get("data", [])
        if not connections:
            return https_fn.Response(
                json.dumps({"success": False, "error": "No patient connections found"}),
                status=404,
                headers=headers,
            )

        # Step 3: Get graph data for first connection
        connection = connections[0]
        patient_id = connection.get("patientId")
        
        graph_response = libre_get_graph_data(base_url, token, user_id, patient_id)
        
        if graph_response.get("status") != 0:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Failed to get graph data"}),
                status=500,
                headers=headers,
            )

        graph_data = graph_response.get("data", {}).get("graphData", [])
        current_measurement = graph_response.get("data", {}).get("connection", {}).get("glucoseMeasurement", {})

        # Format the graph data
        formatted_history = []
        for item in graph_data:
            formatted_history.append({
                "value": item.get("ValueInMgPerDl") or item.get("Value"),
                "time": item.get("Timestamp"),
                "isHigh": item.get("isHigh", False),
                "isLow": item.get("isLow", False),
            })

        return https_fn.Response(
            json.dumps({
                "success": True,
                "current": {
                    "value": current_measurement.get("ValueInMgPerDl") or current_measurement.get("Value"),
                    "trend": LIBRE_TREND_ARROWS.get(current_measurement.get("TrendArrow", 3), "unknown"),
                    "trendArrow": current_measurement.get("TrendArrow"),
                    "time": current_measurement.get("Timestamp"),
                    "isHigh": current_measurement.get("isHigh", False),
                    "isLow": current_measurement.get("isLow", False),
                },
                "history": formatted_history,
                "historyCount": len(formatted_history),
                "source": "librelinkup"
            }),
            status=200,
            headers=headers,
        )

    except Exception as e:
        return https_fn.Response(
            json.dumps({
                "success": False,
                "error": str(e),
                "type": type(e).__name__
            }),
            status=500,
            headers=headers,
        )


@https_fn.on_request()
def get_libre_connections(req: https_fn.Request) -> https_fn.Response:
    """Get all patient connections from LibreLinkUp (useful for multi-patient setups)."""
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    if req.method == "OPTIONS":
        return https_fn.Response("", status=204, headers=headers)

    try:
        data = req.get_json() if req.get_json() else {}
        email = data.get("email", "")
        password = data.get("password", "")
        region = data.get("region", "eu")

        if not email or not password:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Email and password are required"}),
                status=400,
                headers=headers,
            )

        # Login
        login_response = libre_login(email, password, region)
        
        if login_response.get("status") != 0:
            error_msg = login_response.get("error", {}).get("message", "Login failed")
            return https_fn.Response(
                json.dumps({"success": False, "error": error_msg}),
                status=401,
                headers=headers,
            )

        auth_ticket = login_response.get("data", {}).get("authTicket", {})
        token = auth_ticket.get("token")
        user_id = login_response.get("data", {}).get("user", {}).get("id")
        base_url = login_response.get("_base_url")

        # Get connections
        connections_response = libre_get_connections(base_url, token, user_id)
        
        if connections_response.get("status") != 0:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Failed to get connections"}),
                status=500,
                headers=headers,
            )

        connections = connections_response.get("data", [])
        
        # Format connections
        formatted_connections = []
        for conn in connections:
            glucose = conn.get("glucoseMeasurement", {})
            formatted_connections.append({
                "patientId": conn.get("patientId"),
                "firstName": conn.get("firstName"),
                "lastName": conn.get("lastName"),
                "targetLow": conn.get("targetLow"),
                "targetHigh": conn.get("targetHigh"),
                "currentGlucose": glucose.get("ValueInMgPerDl") or glucose.get("Value"),
                "trend": LIBRE_TREND_ARROWS.get(glucose.get("TrendArrow", 3), "unknown"),
                "time": glucose.get("Timestamp"),
                "isHigh": glucose.get("isHigh", False),
                "isLow": glucose.get("isLow", False),
            })

        return https_fn.Response(
            json.dumps({
                "success": True,
                "connections": formatted_connections,
                "count": len(formatted_connections),
            }),
            status=200,
            headers=headers,
        )

    except Exception as e:
        return https_fn.Response(
            json.dumps({
                "success": False,
                "error": str(e),
                "type": type(e).__name__
            }),
            status=500,
            headers=headers,
        )