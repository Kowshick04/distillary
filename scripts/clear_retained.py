import json
import time
import paho.mqtt.client as mqtt

def clear_retained():
    # WebSocket port 8083 is used by flutter, but for paho-mqtt plain TCP port 1883 is easier and faster
    client = mqtt.Client(client_id="clear_retained_script")
    
    print("Connecting to broker.hivemq.com on port 1883...")
    client.connect("broker.hivemq.com", 1883, 60)
    client.loop_start()
    
    # Wait for connection
    time.sleep(1.0)
    
    factories = ["F01", "F02", "F03", "F04", "F05"]
    for f in factories:
        topic = f"distillery/factory/{f}/telemetry"
        
        # Build clean initial/standby payload
        payload = {
            "factoryCode": f,
            "excelTimestamp": "12:00",
            "fermenter": 1,
            "pf": "PF-1",
            "alert": "NORMAL",
            "actualProduction": 1575.9,
            "feEfficiency": 90.6,
            "washAlcohol": 12.9,
            "ethanolPct": 12.9,
            "temperature": 76.1,
            "pressure": 0.63,
            "vacuum": -0.62,
            "deltaP": 0.22,
            "setupPh": 4.5,
            "finalPh": 4.48,
            "setupSg": 1.085,
            "finalSg": 1.010,
            "feedingHours": 18.5,
            "retentionHours": 48.0,
            "confidence": 0.94,
            "spentwashRecycle": 6.0,
            "analyserTemp": 76.1,
            "feedRate": 54.7,
            "concSpentwashBrix": 56.4,
            "alcoholLossSpentwash": 0.05,
            "washAlcoholFeed": 12.9,
            "bottomSpentwashBrix": 4.6,
            "rawSpentwashBrix": 14.7,
            "ffeOutletBrix": 27.7,
            "productAlcoholFinal": 99.9,
            "fermenters": [
                {"id": 1, "status": "AWAITING_SYNC", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "AWAITING SYNC"},
                {"id": 2, "status": "AWAITING_SYNC", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "AWAITING SYNC"},
                {"id": 3, "status": "AWAITING_SYNC", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "AWAITING SYNC"},
                {"id": 4, "status": "AWAITING_SYNC", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "AWAITING SYNC"}
            ],
            "distillation": {
                "washAlcohol": 12.9,
                "feedRate": 54.7,
                "finalAlcohol": 99.9,
                "alcoholLoss": 0.05,
                "spentWashFeed": 54.7,
                "analyserColumn": 76.1,
                "ffe": 27.7,
                "spentWashTank": 4.6,
                "rcStrength": 99.9,
                "msdh": 98.2,
                "ethanol": 99.9,
                "rawSpentWashBrix": 14.7,
                "bottomSpentWashBrix": 4.6,
                "ffeOutletBrix": 27.7,
                "concentratedBrix": 56.4,
                "spentWashRecycle": 6.0
            }
        }
        
        print(f"Publishing clean payload to {topic} with retain=True...")
        client.publish(topic, json.dumps(payload), qos=1, retain=True)
        
    time.sleep(2.0)
    client.loop_stop()
    client.disconnect()
    print("Done!")

if __name__ == "__main__":
    clear_retained()
