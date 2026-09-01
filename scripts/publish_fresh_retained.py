import paho.mqtt.client as mqtt
import time
import json

FACTORIES = [
    {
        "factoryCode": "F01",
        "fileName": "Haliyal_170KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 4,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 118.03,
        "feEfficiency": 93.5,
        "washAlcohol": 12.98,
        "ethanolPct": 99.82,
        "temperature": 76.08,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.5,
        "finalPh": 4.48,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 85.0,
        "spentwashRecycle": 6.0,
        "analyserTemp": 76.08,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 12.98,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.82,
        "fermenters": [
            {"id": 1, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 2, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 3, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 4, "status": "GOLDEN BATCH", "subStatus": "FERMENTING", "temp": 32.35, "ph": 4.48, "brix": 1.0, "yeast": "320M", "va": "80p", "vol": 92, "aiPredict": "GOLDEN BATCH"}
        ],
        "distillation": {
            "washAlcohol": 12.98, "feedRate": 54.7, "finalAlcohol": 99.82, "alcoholLoss": 0.05,
            "spentWashFeed": 54.7, "analyserColumn": 76.08, "ffe": 27.7, "spentWashTank": 6.0,
            "rcStrength": 99.82, "msdh": 98.2, "ethanol": 99.82, "rawSpentWashBrix": 14.7,
            "bottomSpentWashBrix": 4.6, "ffeOutletBrix": 27.7, "concentratedBrix": 56.4, "spentWashRecycle": 6.0
        }
    },
    {
        "factoryCode": "F02",
        "fileName": "Sankili_168KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 4,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 112.58,
        "feEfficiency": 90.5,
        "washAlcohol": 12.68,
        "ethanolPct": 99.87,
        "temperature": 76.32,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.5,
        "finalPh": 4.48,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 76.9,
        "spentwashRecycle": 6.0,
        "analyserTemp": 76.32,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 12.68,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.87,
        "fermenters": [
            {"id": 1, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 2, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 3, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 4, "status": "GOLDEN BATCH", "subStatus": "FERMENTING", "temp": 32.35, "ph": 4.48, "brix": 1.0, "yeast": "320M", "va": "80p", "vol": 92, "aiPredict": "GOLDEN BATCH"}
        ],
        "distillation": {
            "washAlcohol": 12.68, "feedRate": 54.7, "finalAlcohol": 99.87, "alcoholLoss": 0.05,
            "spentWashFeed": 54.7, "analyserColumn": 76.32, "ffe": 27.7, "spentWashTank": 6.0,
            "rcStrength": 99.87, "msdh": 98.2, "ethanol": 99.87, "rawSpentWashBrix": 14.7,
            "bottomSpentWashBrix": 4.6, "ffeOutletBrix": 27.7, "concentratedBrix": 56.4, "spentWashRecycle": 6.0
        }
    },
    {
        "factoryCode": "F03",
        "fileName": "Nellikuppam_120KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 2,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 76.81,
        "feEfficiency": 86.2,
        "washAlcohol": 11.79,
        "ethanolPct": 99.76,
        "temperature": 76.83,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.45,
        "finalPh": 4.41,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 78.0,
        "spentwashRecycle": 6.0,
        "analyserTemp": 76.83,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 11.79,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.76,
        "fermenters": [
            {"id": 1, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 2, "status": "GOLDEN BATCH", "subStatus": "FERMENTING", "temp": 30.6, "ph": 4.41, "brix": 4.0, "yeast": "0M", "va": "0p", "vol": 80, "aiPredict": "GOLDEN"},
            {"id": 3, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 4, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"}
        ],
        "distillation": {
            "washAlcohol": 11.79, "feedRate": 54.7, "finalAlcohol": 99.76, "alcoholLoss": 0.05,
            "spentWashFeed": 54.7, "analyserColumn": 76.83, "ffe": 27.7, "spentWashTank": 6.0,
            "rcStrength": 99.76, "msdh": 98.2, "ethanol": 99.76, "rawSpentWashBrix": 14.7,
            "bottomSpentWashBrix": 4.6, "ffeOutletBrix": 27.7, "concentratedBrix": 56.4, "spentWashRecycle": 6.0
        }
    },
    {
        "factoryCode": "F04",
        "fileName": "Sivagangai_64KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 1,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 45.97,
        "feEfficiency": 92.9,
        "washAlcohol": 13.87,
        "ethanolPct": 99.95,
        "temperature": 75.82,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.5,
        "finalPh": 4.48,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 85.3,
        "spentwashRecycle": 6.0,
        "analyserTemp": 75.82,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 13.87,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.95,
        "fermenters": [
            {"id": 1, "status": "GOLDEN BATCH", "subStatus": "FERMENTING", "temp": 32.35, "ph": 4.48, "brix": 1.0, "yeast": "320M", "va": "80p", "vol": 92, "aiPredict": "GOLDEN BATCH"},
            {"id": 2, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 3, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 4, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"}
        ],
        "distillation": {
            "washAlcohol": 13.87, "feedRate": 54.7, "finalAlcohol": 99.95, "alcoholLoss": 0.05,
            "spentWashFeed": 54.7, "analyserColumn": 75.82, "ffe": 27.7, "spentWashTank": 6.0,
            "rcStrength": 99.95, "msdh": 98.2, "ethanol": 99.95, "rawSpentWashBrix": 14.7,
            "bottomSpentWashBrix": 4.6, "ffeOutletBrix": 27.7, "concentratedBrix": 56.4, "spentWashRecycle": 6.0
        }
    },
    {
        "factoryCode": "F05",
        "fileName": "Bagalkot_60KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 2,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 39.45,
        "feEfficiency": 89.0,
        "washAlcohol": 12.58,
        "ethanolPct": 99.66,
        "temperature": 76.96,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.5,
        "finalPh": 4.48,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 89.4,
        "spentwashRecycle": 6.0,
        "analyserTemp": 76.96,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 12.58,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.66,
        "fermenters": [
            {"id": 1, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 2, "status": "GOLDEN BATCH", "subStatus": "FERMENTING", "temp": 32.35, "ph": 4.48, "brix": 1.0, "yeast": "320M", "va": "80p", "vol": 92, "aiPredict": "GOLDEN BATCH"},
            {"id": 3, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"},
            {"id": 4, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "STANDBY"}
        ],
        "distillation": {
            "washAlcohol": 12.58, "feedRate": 54.7, "finalAlcohol": 99.66, "alcoholLoss": 0.05,
            "spentWashFeed": 54.7, "analyserColumn": 76.96, "ffe": 27.7, "spentWashTank": 6.0,
            "rcStrength": 99.66, "msdh": 98.2, "ethanol": 99.66, "rawSpentWashBrix": 14.7,
            "bottomSpentWashBrix": 4.6, "ffeOutletBrix": 27.7, "concentratedBrix": 56.4, "spentWashRecycle": 6.0
        }
    }
]

client = mqtt.Client()
client.connect("broker.hivemq.com", 1883, 60)
client.loop_start()
time.sleep(1)

for f in FACTORIES:
    topic = f"distillery/factory/{f['factoryCode']}/telemetry"
    payload = json.dumps(f)
    client.publish(topic, payload, qos=1, retain=True)
    print(f"Published retained to {topic} with fileName: {f['fileName']}")

time.sleep(2)
client.loop_stop()
client.disconnect()
print("All 5 factories refreshed with retain=True on broker.hivemq.com!")
