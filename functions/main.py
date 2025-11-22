# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app
import json

initialize_app()

# okej JEŻELI dobrze rozumiem, to trzeba się z tego zalogować somehow
# ale nie jestem w stanie się zalogować bo nie zakładałem konta na tym? 
# WYDAJE MI SIĘ że Ania by musiała, ale nie jestem kompletnie pewny
# Sprawdźcie ten plik oraz requirements.txt - jest szansa, że źle to zimportowałem kompletnie
# sprawdźcie jeszcez C:\Users\Gabriel\Desktop\diabetes app\diabetes_app\linux\flutter\generated_plugin_registrant.h
# bo tam coś jest czerwone (flutter linux) i ja naprawdę nie wiem
# w requirements.txt było jeszcze firebase_functions~=0.1.0 na początku 
# to pewnie było w chuj ważne (a ja to ofc zmieniłem), ale jest solidna szansa, że nie było wazne
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
        # tak się ogólnie nie robi ale tonący brzytwy się chwyta
        from pydexcom import Dexcom
        
        data = req.get_json() if req.get_json() else {}
        username = data.get('username', 'USERNAME')
        password = data.get('password', 'PASSWORD')
        
        # czemu region nie wykrywa przeciez w dokumentacji jest tak wlasnie
        dexcom = Dexcom(username=username, password=password, region='ous') 
        bg = dexcom.get_current_glucose_reading()
        return https_fn.Response(
            json.dumps({
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
                "error": str(e),
                "type": type(e).__name__
            }),
            status=500,
            headers=headers
        )


set_global_options(max_instances=5)

# initialize_app()
#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")