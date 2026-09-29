import paho.mqtt.client as mqtt
import json
import time

def publish_live_update():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.connect("broker.hivemq.com", 1883, 60)
    client.loop_start()
    
    # We update F01 with distinct, easily recognizable values
    live_payload = {
        "factoryCode": "F01",
        "fileName": "Haliyal_170KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "LIVE 10:15",
        "fermenter": 1,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 122.50,
        "feEfficiency": 96.5,
        "washAlcohol": 14.8,
        "ethanolPct": 99.90,
        "temperature": 77.20,
        "pressure": 0.65,
        "vacuum": -0.60,
        "deltaP": 0.24,
        "setupPh": 4.75,
        "finalPh": 4.75,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 98.0,
        "spentwashRecycle": 6.5,
        "analyserTemp": 77.20,
        "feedRate": 56.0,
        "concSpentwashBrix": 57.0,
        "alcoholLossSpentwash": 0.04,
        "washAlcoholFeed": 14.8,
        "bottomSpentwashBrix": 4.5,
        "rawSpentwashBrix": 15.0,
        "ffeOutletBrix": 28.0,
        "productAlcoholFinal": 99.90,
        "fermenters": [
            {
                "id": 1,
                "status": "GOLDEN",
                "subStatus": "FERMENTING",
                "temp": 33.2,
                "ph": 4.75,
                "brix": 2.4,
                "yeast": "395M",
                "va": "55p",
                "vol": 88,
                "confidence": 98.0,
                "aiPredict": "GOLDEN"
            },
            {
                "id": 2,
                "status": "STANDBY",
                "subStatus": "",
                "temp": 0.0,
                "ph": 0.0,
                "brix": 0.0,
                "yeast": "0M",
                "va": "0p",
                "vol": 0,
                "confidence": 0.0,
                "aiPredict": "STANDBY"
            },
            {
                "id": 3,
                "status": "STANDBY",
                "subStatus": "",
                "temp": 0.0,
                "ph": 0.0,
                "brix": 0.0,
                "yeast": "0M",
                "va": "0p",
                "vol": 0,
                "confidence": 0.0,
                "aiPredict": "STANDBY"
            },
            {
                "id": 4,
                "status": "GOLDEN",
                "subStatus": "FERMENTING",
                "temp": 32.8,
                "ph": 4.62,
                "brix": 2.9,
                "yeast": "338M",
                "va": "52p",
                "vol": 82,
                "confidence": 91.0,
                "aiPredict": "GOLDEN"
            }
        ],
        "distillation": {
            "washAlcohol": 14.8,
            "feedRate": 56.0,
            "finalAlcohol": 99.90,
            "alcoholLoss": 0.04,
            "spentWashFeed": 56.0,
            "analyserColumn": 77.20,
            "ffe": 28.0,
            "spentWashTank": 6.5,
            "rcStrength": 99.90,
            "msdh": 98.5,
            "ethanol": 99.90,
            "rawSpentWashBrix": 15.0,
            "bottomSpentWashBrix": 4.5,
            "ffeOutletBrix": 28.0,
            "concentratedBrix": 57.0,
            "spentWashRecycle": 6.5
        }
    }
    
    topic = "distillery/factory/F01/telemetry"
    result = client.publish(topic, json.dumps(live_payload), qos=1, retain=True)
    result.wait_for_publish(timeout=5)
    print(f"[SUCCESS] Published live test telemetry to {topic} with retain=True")
    time.sleep(1)
    client.loop_stop()
    client.disconnect()

if __name__ == "__main__":
    publish_live_update()
