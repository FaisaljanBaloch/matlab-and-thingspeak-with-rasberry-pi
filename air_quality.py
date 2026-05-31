from sds011lib import SDS011QueryReader

import time
import requests

# CONFIG
WRITE_API_KEY = "YOUR_WRITE_API_KEY_HERE"
THINGSPEAK_URL = "https://api.thingspeak.com/update"
INTERVAL = 15  # (ThingSpeak free tier: min 15s)

def read_sds011():

    # Create a query mode reader.
    reader = SDS011QueryReader('/dev/ttyUSB0')
    
    # Query the device
    result = reader.query()
    
    # Return PM values
    return result.pm25, result.pm10

def send_to_thingspeak(pm25, pm10):
    payload = {
        "api_key": WRITE_API_KEY,
        "field1": pm25,
        "field2": pm10
    }
    response = requests.post(
        THINGSPEAK_URL,
        data=payload  # 'data=' sends as form-encoded body (POST)
    )
    return response.json().get("entry_id", "error")

while True:
    try:
        pm25, pm10 = read_sds011()
        print(f"PM2.5: {pm25} µg/m³ | PM10: {pm10} µg/m³")
        
        result = send_to_thingspeak(pm25, pm10)
        print(f"Sent to ThingSpeak → Entry ID: {result}")
    
    except Exception as e:
        print(f"Error: {e}")

    # Send data every minute
    time.sleep(INTERVAL)