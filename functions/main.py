# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn, scheduler_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore
import json
import datetime
import os

initialize_app()
set_global_options(max_instances=5)


LIBRE_TREND_ARROWS = {
    1: "falling_quickly",
    2: "falling",
    3: "stable",
    4: "rising",
    5: "rising_quickly",
}


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
    """Get current glucose reading from LibreLinkUp API using pylibrelinkup."""
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    if req.method == "OPTIONS":
        return https_fn.Response("", status=204, headers=headers)

    try:
        from pylibrelinkup import PyLibreLinkUp, APIUrl, RedirectError

        data = req.get_json() if req.get_json() else {}
        email = data.get("email", "")
        password = data.get("password", "")

        if not email or not password:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Email and password are required"}),
                status=400,
                headers=headers,
            )

        api_url = APIUrl.EU
        client = PyLibreLinkUp(email=email, password=password, api_url=api_url)
        
        try:
            client.authenticate()
        except RedirectError as e:
            client = PyLibreLinkUp(email=email, password=password, api_url=e.region)
            client.authenticate()

        patients = client.get_patients()
        if not patients:
            return https_fn.Response(
                json.dumps({"success": False, "error": "No patient connections found. Make sure LibreLinkUp sharing is set up."}),
                status=404,
                headers=headers,
            )

        patient = patients[0]
        latest = client.latest(patient_identifier=patient)

        if not latest:
            return https_fn.Response(
                json.dumps({"success": False, "error": "No glucose measurement available"}),
                status=404,
                headers=headers,
            )

        # Get trend value (Trend is an IntEnum: 1=DOWN_FAST, 2=DOWN_SLOW, 3=STABLE, 4=UP_SLOW, 5=UP_FAST)
        trend_value = int(latest.trend)  # Trend enum to int
        trend_str = LIBRE_TREND_ARROWS.get(trend_value, "unknown")

        return https_fn.Response(
            json.dumps({
                "success": True,
                "value": latest.value_in_mg_per_dl,
                "trend": trend_str,
                "trendArrow": trend_value,
                "time": str(latest.timestamp),
                "isHigh": latest.is_high,
                "isLow": latest.is_low,
                "patientName": f"{patient.first_name} {patient.last_name}".strip(),
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
    """Get glucose history (graph data) from LibreLinkUp API using pylibrelinkup."""
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    if req.method == "OPTIONS":
        return https_fn.Response("", status=204, headers=headers)

    try:
        from pylibrelinkup import PyLibreLinkUp, APIUrl, RedirectError

        data = req.get_json() if req.get_json() else {}
        email = data.get("email", "")
        password = data.get("password", "")

        if not email or not password:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Email and password are required"}),
                status=400,
                headers=headers,
            )

        # Initialize client - default to EU region, handle redirect if needed
        api_url = APIUrl.EU
        client = PyLibreLinkUp(email=email, password=password, api_url=api_url)
        
        try:
            client.authenticate()
        except RedirectError as e:
            # User is in a different region, retry with the correct one
            client = PyLibreLinkUp(email=email, password=password, api_url=e.region)
            client.authenticate()

        # Get patients
        patients = client.get_patients()
        if not patients:
            return https_fn.Response(
                json.dumps({"success": False, "error": "No patient connections found"}),
                status=404,
                headers=headers,
            )

        # Get graph data and latest for first patient
        patient = patients[0]
        graph_data = client.graph(patient_identifier=patient)
        latest = client.latest(patient_identifier=patient)

        # Format the graph data (GlucoseMeasurement has value_in_mg_per_dl, timestamp, is_high, is_low)
        formatted_history = []
        for item in graph_data:
            formatted_history.append({
                "value": item.value_in_mg_per_dl,
                "time": str(item.timestamp),
                "isHigh": item.is_high,
                "isLow": item.is_low,
            })

        # Current measurement (GlucoseMeasurementWithTrend has trend as Trend enum)
        current = {}
        if latest:
            trend_value = int(latest.trend)  # Trend enum to int
            trend_str = LIBRE_TREND_ARROWS.get(trend_value, "unknown")
            
            current = {
                "value": latest.value_in_mg_per_dl,
                "trend": trend_str,
                "trendArrow": trend_value,
                "time": str(latest.timestamp),
                "isHigh": latest.is_high,
                "isLow": latest.is_low,
            }

        return https_fn.Response(
            json.dumps({
                "success": True,
                "current": current,
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
        from pylibrelinkup import PyLibreLinkUp, APIUrl, RedirectError

        data = req.get_json() if req.get_json() else {}
        email = data.get("email", "")
        password = data.get("password", "")

        if not email or not password:
            return https_fn.Response(
                json.dumps({"success": False, "error": "Email and password are required"}),
                status=400,
                headers=headers,
            )

        # Initialize client - default to EU region, handle redirect if needed
        api_url = APIUrl.EU
        client = PyLibreLinkUp(email=email, password=password, api_url=api_url)
        
        try:
            client.authenticate()
        except RedirectError as e:
            # User is in a different region, retry with the correct one
            client = PyLibreLinkUp(email=email, password=password, api_url=e.region)
            client.authenticate()

        # Get patients (Patient has: patient_id, first_name, last_name)
        patients = client.get_patients()
        
        # Format connections
        formatted_connections = []
        for patient in patients:
            # Get latest glucose for each patient
            latest = client.latest(patient_identifier=patient)
            
            trend_value = 3
            trend_str = "stable"
            current_glucose = None
            timestamp = None
            is_high = False
            is_low = False
            
            if latest:
                trend_value = int(latest.trend)  # Trend enum to int
                trend_str = LIBRE_TREND_ARROWS.get(trend_value, "unknown")
                current_glucose = latest.value_in_mg_per_dl
                timestamp = str(latest.timestamp)
                is_high = latest.is_high
                is_low = latest.is_low

            formatted_connections.append({
                "patientId": str(patient.patient_id),
                "firstName": patient.first_name,
                "lastName": patient.last_name,
                "targetLow": None,  # Patient model doesn't have target_low/target_high
                "targetHigh": None,
                "currentGlucose": current_glucose,
                "trend": trend_str,
                "time": timestamp,
                "isHigh": is_high,
                "isLow": is_low,
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