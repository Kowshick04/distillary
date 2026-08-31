import os
import io
import time
import sqlite3
import joblib
import pandas as pd
import requests
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
from google.oauth2 import service_account

# Configuration
DRIVE_FOLDER_ID = "YOUR_GOOGLE_DRIVE_FOLDER_ID"
CREDENTIALS_FILE = "credentials.json"
API_URL = "http://localhost:5000/api/v1/distillery/logs"
MODEL_PATH = "batch_quality_classifier.joblib"
STATE_DB = "processed_files.db"

def init_state_db():
    conn = sqlite3.connect(STATE_DB)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS processed_files (
            file_id TEXT PRIMARY KEY,
            filename TEXT,
            processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    conn.close()

def is_processed(file_id):
    conn = sqlite3.connect(STATE_DB)
    cursor = conn.cursor()
    cursor.execute("SELECT 1 FROM processed_files WHERE file_id = ?", (file_id,))
    result = cursor.fetchone()
    conn.close()
    return result is not None

def mark_processed(file_id, filename):
    conn = sqlite3.connect(STATE_DB)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO processed_files (file_id, filename) VALUES (?, ?)", (file_id, filename))
    conn.commit()
    conn.close()

def get_drive_service():
    creds = service_account.Credentials.from_service_account_file(
        CREDENTIALS_FILE,
        scopes=['https://www.googleapis.com/auth/drive.readonly']
    )
    return build('drive', 'v3', credentials=creds)

def download_file(service, file_id):
    request = service.files().get_media(fileId=file_id)
    fh = io.BytesIO()
    downloader = MediaIoBaseDownload(fh, request)
    done = False
    while not done:
        status, done = downloader.next_chunk()
    fh.seek(0)
    return fh

def process_excel(file_bytes):
    # Parse the active spreadsheet
    df = pd.read_excel(file_bytes, sheet_name="Synthetic Data", skiprows=5, header=None)
    df = df.dropna(subset=[2]).copy()
    row = df[df[2] != "Date"].iloc[-1] # Fetch the latest run record row
    
    # Extract features matching the model inputs
    features = {
        "feeding_hours": float(row[8]),
        "retention_hours": float(row[9]),
        "setup_sg": float(row[28]),
        "final_sg": float(row[29]),
        "sg_diff": float(row[30]),
        "setup_alc": float(row[31]),
        "final_alc": float(row[32]),
        "setup_ph": float(row[35]),
        "final_ph": float(row[36])
    }
    
    # Extract raw data to store
    raw_data = {
        "date": str(row[2]).split()[0],
        "fermenter": int(row[4]),
        "pf": str(row[3]).strip(),
        "feedingHours": float(row[8]),
        "retentionHours": float(row[9]),
        "setupSg": float(row[28]),
        "finalSg": float(row[29]),
        "setupPh": float(row[35]),
        "finalPh": float(row[36]),
        "actualProduction": float(row[45]),
        "feEfficiency": float(row[46]),
        "ethanolPct": float(row[68])
    }
    
    return features, raw_data

def run_pipeline():
    init_state_db()
    
    if not os.path.exists(CREDENTIALS_FILE):
        print(f"Waiting for credentials file '{CREDENTIALS_FILE}' to be configured...")
        return
        
    if not os.path.exists(MODEL_PATH):
        print(f"Waiting for AI model '{MODEL_PATH}' to be configured...")
        return

    service = get_drive_service()
    
    # Query for Excel sheets in folder
    query = f"'{DRIVE_FOLDER_ID}' in parents and mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'"
    results = service.files().list(q=query, fields="files(id, name)").execute()
    files = results.get('files', [])
    
    if not files:
        print("No Excel sheets found in Drive folder.")
        return
        
    # Load AI Model
    model = joblib.load(MODEL_PATH)
    
    for f in files:
        file_id = f['id']
        filename = f['name']
        
        if is_processed(file_id):
            continue
            
        print(f"Processing new file: {filename} ({file_id})...")
        try:
            file_bytes = download_file(service, file_id)
            features, raw_data = process_excel(file_bytes)
            
            # AI Inference
            input_df = pd.DataFrame([features])
            prediction = int(model.predict(input_df)[0])
            # RandomForest confidence (using class probabilities)
            probabilities = model.predict_proba(input_df)[0]
            confidence = float(probabilities[prediction]) * 100
            
            alert_label = ["Low Alcohol", "Normal", "Golden Batch"][prediction]
            
            # Send payload to backend server
            payload = {
                "raw_data": raw_data,
                "prediction": {
                    "label": alert_label,
                    "confidence": confidence
                }
            }
            response = requests.post(API_URL, json=payload)
            if response.status_code == 200:
                mark_processed(file_id, filename)
                print(f"Successfully processed and posted {filename}")
            else:
                print(f"Failed to post data for {filename}: {response.text}")
                
        except Exception as e:
            print(f"Error processing file {filename}: {e}")

if __name__ == "__main__":
    while True:
        try:
            run_pipeline()
        except Exception as err:
            print(f"Pipeline running error: {err}")
        time.sleep(30) # Poll Drive folder every 30 seconds
