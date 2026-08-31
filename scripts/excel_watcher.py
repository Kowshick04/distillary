import os
import time
import json
import random
import shutil
from datetime import datetime
import pandas as pd
import joblib
import paho.mqtt.client as mqtt
import threading

# Configuration Paths
WATCH_DIR = r"C:\Users\Admin B\StudioProjects\Distillary\excel_drops"
PROCESSED_DIR = os.path.join(WATCH_DIR, "processed")
MODEL_PATH = r"C:\Users\Admin B\StudioProjects\Distillary\server\batch_quality_classifier.joblib"
LOG_FILE = os.path.join(WATCH_DIR, "watcher_log.txt")
BROKER = "broker.hivemq.com"
PORT = 1883

active_streams = set()
active_streams_lock = threading.Lock()

def log_message(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    formatted = f"[{timestamp}] {msg}\n"
    print(formatted, end="", flush=True)
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(formatted)
    except Exception:
        pass

def get_factory_code_from_path(filepath):
    name_lower = filepath.replace('\\', '/').lower()
    if "haliyal" in name_lower or "f01" in name_lower:
        return "F01"
    if "sankili" in name_lower or "f02" in name_lower:
        return "F02"
    if "nellikuppam" in name_lower or "f03" in name_lower:
        return "F03"
    if "sivaganga" in name_lower or "sivagangai" in name_lower or "f04" in name_lower:
        return "F04"
    if "bagalkot" in name_lower or "f05" in name_lower:
        return "F05"
    return "F01"  # Default fallback

def stream_file_rows(filepath, client, model, filename, factory_code):
    try:
        # 1. Parse Excel
        df = pd.read_excel(filepath, sheet_name="Synthetic Data", skiprows=5, header=None)
        df_clean = df[df[2] != "Date"].dropna(subset=[2]).copy()
        
        total_rows = len(df_clean)
        log_message(f"[{factory_code}] Starting live simulation stream for {filename} ({total_rows} rows)")

        # Stream row by row
        for idx, (_, row) in enumerate(df_clean.iterrows(), 1):
            # check if file still exists (to allow stopping stream if file gets deleted/replaced)
            if not os.path.exists(filepath):
                log_message(f"[{factory_code}] Stream interrupted: File {filename} was removed.")
                break

            # 2. Extract 9 features for AI Model
            features = {
                "feeding_hours": float(row[8]) if not pd.isna(row[8]) else 0.0,
                "retention_hours": float(row[9]) if not pd.isna(row[9]) else 0.0,
                "setup_sg": float(row[28]) if not pd.isna(row[28]) else 0.0,
                "final_sg": float(row[29]) if not pd.isna(row[29]) else 0.0,
                "sg_diff": float(row[30]) if not pd.isna(row[30]) else 0.0,
                "setup_alc": float(row[31]) if not pd.isna(row[31]) else 0.0,
                "final_alc": float(row[32]) if not pd.isna(row[32]) else 0.0,
                "setup_ph": float(row[35]) if not pd.isna(row[35]) else 0.0,
                "final_ph": float(row[36]) if not pd.isna(row[36]) else 0.0
            }
            
            # 3. Model Inference & Quality Prediction
            input_df = pd.DataFrame([features])
            prediction = int(model.predict(input_df)[0])
            probabilities = model.predict_proba(input_df)[0]
            confidence = float(probabilities[prediction])
            
            # Model predicted labels (mapped to what empty_app expects)
            labels = ["RISK (INFECTION)", "NORMAL", "GOLDEN BATCH"]
            alert_label = labels[prediction]
            
            # 4. Extract telemetry and parameters
            fermenter_id = int(row[4]) if not pd.isna(row[4]) else 1
            pf_str = str(row[3]).strip() if not pd.isna(row[3]) else "PF-1"
            efficiency = float(row[46]) if not pd.isna(row[46]) else 90.0
            if 0.0 < efficiency <= 1.0:
                efficiency *= 100.0
            ethanol = float(row[68]) if not pd.isna(row[68]) else 12.0
            production = float(row[45]) if not pd.isna(row[45]) else 1500.0
            
            setup_ph_val = float(row[35]) if not pd.isna(row[35]) else 4.5
            final_ph_val = float(row[36]) if not pd.isna(row[36]) else 4.45
            setup_sg_val = float(row[28]) if not pd.isna(row[28]) else 1.085
            final_sg_val = float(row[29]) if not pd.isna(row[29]) else 1.010
            feed_r_val = float(row[18]) if not pd.isna(row[18]) else 54.0
            
            # Construct the conformed 4-vessel state array
            target_fermenter_id = min(4, max(1, fermenter_id))
            fermenters = []
            for i in range(1, 5):
                if i == target_fermenter_id:
                    fermenters.append({
                        "id": target_fermenter_id,  # Real Excel fermenter ID
                        "status": "NORMAL" if alert_label != "RISK (INFECTION)" else "ALERT",
                        "subStatus": "FERMENTING",
                        "temp": round(random.uniform(32.2, 33.8), 1),
                        "ph": final_ph_val,
                        "brix": final_sg_val,
                        "yeast": "310M",
                        "va": "85p",
                        "vol": 85,
                        "aiPredict": "GOLDEN" if alert_label == "GOLDEN BATCH" else ("RISK" if alert_label == "RISK (INFECTION)" else "NORMAL")
                    })
                else:
                    fermenters.append({
                        "id": i,
                        "status": "AWAITING_SYNC",
                        "subStatus": "",
                        "temp": 0.0,
                        "ph": 0.0,
                        "brix": 0.0,
                        "yeast": "0M",
                        "va": "0p",
                        "vol": 0,
                        "aiPredict": "AWAITING SYNC"
                    })
                    
            # 5. Build telemetry payload
            payload = {
                "factoryCode": factory_code,
                "excelTimestamp": datetime.now().strftime("%I:%M %p"),
                "fermenter": fermenter_id,
                "pf": pf_str,
                "alert": alert_label,
                "actualProduction": production,
                "feEfficiency": efficiency,
                "washAlcohol": features["final_alc"],
                "ethanolPct": ethanol,
                "temperature": round(random.uniform(75.5, 78.5), 1),
                "pressure": 0.63,
                "vacuum": -0.62,
                "deltaP": 0.22,
                "setupPh": setup_ph_val,
                "finalPh": final_ph_val,
                "setupSg": setup_sg_val,
                "finalSg": final_sg_val,
                "feedingHours": float(row[8]) if not pd.isna(row[8]) else 18.5,
                "retentionHours": float(row[9]) if not pd.isna(row[9]) else 48.0,
                "confidence": confidence,
                "fermenters": fermenters,
                "distillation": {
                    "washAlcohol": features["final_alc"],
                    "feedRate": feed_r_val,
                    "finalAlcohol": 99.9,
                    "alcoholLoss": round(random.uniform(0.02, 0.08), 2),
                    "spentWashFeed": feed_r_val,
                    "analyserColumn": round(random.uniform(75.5, 78.5), 1),
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
            
            # 6. Publish directly to MQTT
            topic = f"distillery/factory/{factory_code}/telemetry"
            client.publish(topic, json.dumps(payload))
            
            log_message(f"[{factory_code}] Published row {idx}/{total_rows} - alert: {alert_label} (Eff: {efficiency}%)")
            
            # Step delay (3 seconds per row for visual streaming)
            time.sleep(3.0)

        # 7. Move file to processed folder once completed
        if os.path.exists(filepath):
            dest = os.path.join(PROCESSED_DIR, filename)
            if os.path.exists(dest):
                os.remove(dest)
            shutil.move(filepath, PROCESSED_DIR)
            log_message(f"[{factory_code}] Finished streaming {filename}. Moved to processed subfolder.\n")

    except Exception as e:
        log_message(f"Error streaming file {filename}: {e}\n")
    finally:
        with active_streams_lock:
            active_streams.discard(filename)

def process_and_publish(filepath, client, model):
    filename = os.path.basename(filepath)
    factory_code = get_factory_code_from_path(filepath)
    
    with active_streams_lock:
        if filename in active_streams:
            return
        active_streams.add(filename)
        
    threading.Thread(
        target=stream_file_rows,
        args=(filepath, client, model, filename, factory_code),
        daemon=True
    ).start()

def main():
    if not os.path.exists(MODEL_PATH):
        log_message(f"Error: RandomForest model not found at '{MODEL_PATH}'")
        return
        
    log_message(f"Loading RandomForest AI model from: {MODEL_PATH} ...")
    model = joblib.load(MODEL_PATH)
    log_message("Model loaded successfully.")
    
    log_message(f"Connecting to MQTT Broker [{BROKER}:{PORT}]...")
    client = mqtt.Client(callback_api_version=mqtt.CallbackAPIVersion.VERSION2)
    client.connect(BROKER, PORT, 60)
    client.loop_start()
    
    log_message(f"Excel Directory Watcher active! Drop files in: {WATCH_DIR}\n")
    try:
        while True:
            # Scan folder recursively for excel files
            for root, dirs, files in os.walk(WATCH_DIR):
                if "processed" in root.replace('\\', '/').split('/'):
                    continue
                for file in files:
                    if file.endswith(".xlsx") and not file.startswith('~$'):
                        full_path = os.path.join(root, file)
                        process_and_publish(full_path, client, model)
            time.sleep(1)
    except KeyboardInterrupt:
        log_message("\nWatcher stopped.")
    finally:
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    main()
