import paho.mqtt.client as mqtt
import time
import json

FACTORIES = [
    {
        "factoryCode": "F01",
        "fileName": "Haliyal_170KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 1,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 118.03,
        "feEfficiency": 94.0,
        "washAlcohol": 14.2,
        "ethanolPct": 99.82,
        "temperature": 76.08,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.70,
        "finalPh": 4.70,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 95.0,
        "spentwashRecycle": 6.0,
        "analyserTemp": 76.08,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 14.2,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.82,
        "fermenters": [
            {"id": 1, "status": "GOLDEN", "subStatus": "FERMENTING", "temp": 32.5, "ph": 4.70, "brix": 2.6, "yeast": "350M", "va": "48p", "vol": 85, "confidence": 95.0, "aiPredict": "GOLDEN"},
            {"id": 2, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"},
            {"id": 3, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"},
            {"id": 4, "status": "GOLDEN", "subStatus": "FERMENTING", "temp": 32.8, "ph": 4.62, "brix": 2.9, "yeast": "338M", "va": "52p", "vol": 82, "confidence": 91.0, "aiPredict": "GOLDEN"}
        ],
        "distillation": {
            "washAlcohol": 14.2, "feedRate": 54.7, "finalAlcohol": 99.82, "alcoholLoss": 0.05,
            "spentWashFeed": 54.7, "analyserColumn": 76.08, "ffe": 27.7, "spentWashTank": 6.0,
            "rcStrength": 99.82, "msdh": 98.2, "ethanol": 99.82, "rawSpentWashBrix": 14.7,
            "bottomSpentWashBrix": 4.6, "ffeOutletBrix": 27.7, "concentratedBrix": 56.4, "spentWashRecycle": 6.0
        }
    },
    {
        "factoryCode": "F02",
        "fileName": "Sankili_168KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 1,
        "pf": "PF-1",
        "alert": "NORMAL",
        "actualProduction": 112.58,
        "feEfficiency": 84.0,
        "washAlcohol": 8.8,
        "ethanolPct": 99.87,
        "temperature": 76.32,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.30,
        "finalPh": 4.30,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 72.0,
        "spentwashRecycle": 6.0,
        "analyserTemp": 76.32,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 8.8,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.87,
        "fermenters": [
            {"id": 1, "status": "NORMAL", "subStatus": "FERMENTING", "temp": 31.8, "ph": 4.30, "brix": 5.0, "yeast": "210M", "va": "92p", "vol": 80, "confidence": 72.0, "aiPredict": "NORMAL"},
            {"id": 2, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"},
            {"id": 3, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"},
            {"id": 4, "status": "GOLDEN", "subStatus": "FERMENTING", "temp": 32.6, "ph": 4.68, "brix": 2.7, "yeast": "340M", "va": "54p", "vol": 84, "confidence": 93.0, "aiPredict": "GOLDEN"}
        ],
        "distillation": {
            "washAlcohol": 8.8, "feedRate": 54.7, "finalAlcohol": 99.87, "alcoholLoss": 0.05,
            "spentWashFeed": 54.7, "analyserColumn": 76.32, "ffe": 27.7, "spentWashTank": 6.0,
            "rcStrength": 99.87, "msdh": 98.2, "ethanol": 99.87, "rawSpentWashBrix": 14.7,
            "bottomSpentWashBrix": 4.6, "ffeOutletBrix": 27.7, "concentratedBrix": 56.4, "spentWashRecycle": 6.0
        }
    },
    {
        "factoryCode": "F03",
        "fileName": "Nellikuppam_120KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 1,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 76.81,
        "feEfficiency": 92.0,
        "washAlcohol": 13.8,
        "ethanolPct": 99.76,
        "temperature": 76.83,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.65,
        "finalPh": 4.65,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 92.0,
        "spentwashRecycle": 6.0,
        "analyserTemp": 76.83,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 13.8,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.76,
        "fermenters": [
            {"id": 1, "status": "GOLDEN", "subStatus": "FERMENTING", "temp": 33.4, "ph": 4.65, "brix": 2.8, "yeast": "344M", "va": "51p", "vol": 85, "confidence": 92.0, "aiPredict": "GOLDEN"},
            {"id": 2, "status": "NORMAL", "subStatus": "FERMENTING", "temp": 31.3, "ph": 4.25, "brix": 5.2, "yeast": "195M", "va": "98p", "vol": 80, "confidence": 70.0, "aiPredict": "NORMAL"},
            {"id": 3, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"},
            {"id": 4, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"}
        ],
        "distillation": {
            "washAlcohol": 13.8, "feedRate": 54.7, "finalAlcohol": 99.76, "alcoholLoss": 0.05,
            "spentWashFeed": 54.7, "analyserColumn": 76.83, "ffe": 27.7, "spentWashTank": 6.0,
            "rcStrength": 99.76, "msdh": 98.2, "ethanol": 99.76, "rawSpentWashBrix": 14.7,
            "bottomSpentWashBrix": 4.6, "ffeOutletBrix": 27.7, "concentratedBrix": 56.4, "spentWashRecycle": 6.0
        }
    },
    {
        "factoryCode": "F04",
        "fileName": "Sivagangai_64KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 2,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 45.97,
        "feEfficiency": 89.0,
        "washAlcohol": 13.2,
        "ethanolPct": 99.95,
        "temperature": 75.82,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.58,
        "finalPh": 4.58,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 89.0,
        "spentwashRecycle": 6.0,
        "analyserTemp": 75.82,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 13.2,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.95,
        "fermenters": [
            {"id": 1, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"},
            {"id": 2, "status": "GOLDEN", "subStatus": "FERMENTING", "temp": 32.2, "ph": 4.58, "brix": 3.0, "yeast": "325M", "va": "58p", "vol": 82, "confidence": 89.0, "aiPredict": "GOLDEN"},
            {"id": 3, "status": "NORMAL", "subStatus": "FERMENTING", "temp": 31.5, "ph": 4.35, "brix": 4.8, "yeast": "220M", "va": "88p", "vol": 80, "confidence": 75.0, "aiPredict": "NORMAL"},
            {"id": 4, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"}
        ],
        "distillation": {
            "washAlcohol": 13.2, "feedRate": 54.7, "finalAlcohol": 99.95, "alcoholLoss": 0.05,
            "spentWashFeed": 54.7, "analyserColumn": 75.82, "ffe": 27.7, "spentWashTank": 6.0,
            "rcStrength": 99.95, "msdh": 98.2, "ethanol": 99.95, "rawSpentWashBrix": 14.7,
            "bottomSpentWashBrix": 4.6, "ffeOutletBrix": 27.7, "concentratedBrix": 56.4, "spentWashRecycle": 6.0
        }
    },
    {
        "factoryCode": "F05",
        "fileName": "Bagalkot_60KLPD_Synthetic_Data.xlsx",
        "excelTimestamp": "16:36",
        "fermenter": 1,
        "pf": "PF-1",
        "alert": "GOLDEN BATCH",
        "actualProduction": 39.45,
        "feEfficiency": 96.0,
        "washAlcohol": 14.5,
        "ethanolPct": 99.66,
        "temperature": 76.96,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": 4.72,
        "finalPh": 4.72,
        "setupSg": 1.085,
        "finalSg": 1.010,
        "feedingHours": 18.5,
        "retentionHours": 48.0,
        "confidence": 96.0,
        "spentwashRecycle": 6.0,
        "analyserTemp": 76.96,
        "feedRate": 54.7,
        "concSpentwashBrix": 56.4,
        "alcoholLossSpentwash": 0.05,
        "washAlcoholFeed": 14.5,
        "bottomSpentwashBrix": 4.6,
        "rawSpentwashBrix": 14.7,
        "ffeOutletBrix": 27.7,
        "productAlcoholFinal": 99.66,
        "fermenters": [
            {"id": 1, "status": "GOLDEN", "subStatus": "FERMENTING", "temp": 32.4, "ph": 4.72, "brix": 2.5, "yeast": "360M", "va": "45p", "vol": 88, "confidence": 96.0, "aiPredict": "GOLDEN"},
            {"id": 2, "status": "GOLDEN", "subStatus": "FERMENTING", "temp": 32.7, "ph": 4.67, "brix": 2.6, "yeast": "348M", "va": "49p", "vol": 86, "confidence": 94.0, "aiPredict": "GOLDEN"},
            {"id": 3, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"},
            {"id": 4, "status": "STANDBY", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "confidence": 0.0, "aiPredict": "STANDBY"}
        ],
        "distillation": {
            "washAlcohol": 14.5, "feedRate": 54.7, "finalAlcohol": 99.66, "alcoholLoss": 0.05,
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
