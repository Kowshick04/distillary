import json
import time
import os
from flask import Flask, request, jsonify, Response, render_template
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import joblib
import numpy as np
import paho.mqtt.client as mqtt

# Initialize Non-Blocking MQTT Publisher for Secondary Apps
mqtt_client = None
try:
    mqtt_client = mqtt.Client(client_id="Distillary_Primary_Server")
    mqtt_client.connect("broker.hivemq.com", 1883, 60)
    mqtt_client.loop_start()
    print("MQTT Publisher connected to broker.hivemq.com:1883")
except Exception as _mqtt_e:
    print(f"Non-fatal: MQTT Publisher init warning: {_mqtt_e}")


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///distillery_data.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Load AI Model (RandomForest batch quality classifier)
MODEL_PATH = os.path.join(os.path.dirname(__file__), 'batch_quality_classifier.joblib')
model = None
if os.path.exists(MODEL_PATH):
    try:
        model = joblib.load(MODEL_PATH)
        print(f"Successfully loaded Random Forest model from {MODEL_PATH}")
    except Exception as e:
        print(f"Error loading Random Forest model: {e}")
else:
    print(f"Warning: Model not found at {MODEL_PATH}")

# Database Models
class RawDataLog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    factory_code = db.Column(db.String(20), default='F01') # Added factory routing key
    file_name = db.Column(db.String(255), default='')
    file_url = db.Column(db.String(512), default='')
    date = db.Column(db.String(50))
    fermenter = db.Column(db.Integer)
    pf = db.Column(db.String(50))
    feeding_hours = db.Column(db.Float)
    retention_hours = db.Column(db.Float)
    setup_sg = db.Column(db.Float)
    final_sg = db.Column(db.Float)
    setup_ph = db.Column(db.Float)
    final_ph = db.Column(db.Float)
    actual_production = db.Column(db.Float)
    fe_efficiency = db.Column(db.Float)
    ethanol_pct = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class AIPrediction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    raw_log_id = db.Column(db.Integer, db.ForeignKey('raw_data_log.id'), nullable=False)
    prediction_label = db.Column(db.String(50))
    confidence_score = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    raw_log = db.relationship('RawDataLog', backref=db.backref('predictions', lazy=True))

class OperatorActionLog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    action = db.Column(db.String(255), nullable=False)
    factory_code = db.Column(db.String(20), default='F01')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# SSE Event Manager
class SSEManager:
    def __init__(self):
        self.listeners = []

    def listen(self):
        # Return a generator yielding event stream format
        def stream():
            q = []
            
            # Fetch latest snapshot for each factory from DB and append to q on connection
            try:
                with app.app_context():
                    for code in ['F01', 'F02', 'F03', 'F04', 'F05']:
                        latest_log = RawDataLog.query.filter_by(factory_code=code).order_by(RawDataLog.id.desc()).first()
                        if latest_log:
                            pred = AIPrediction.query.filter_by(raw_log_id=latest_log.id).first()
                            pred_label = pred.prediction_label if pred else "NORMAL"
                            pred_conf = pred.confidence_score if pred else 0.85
                            
                            initial_msg = {
                                "event": "new_distillery_batch",
                                "data": {
                                    "factoryCode":      code,
                                    "date":             latest_log.date,
                                    "fermenter":        latest_log.fermenter,
                                    "pf":               latest_log.pf,
                                    "alert":            pred_label,
                                    "actualProduction": latest_log.actual_production,
                                    "feEfficiency":     latest_log.fe_efficiency,
                                    "ethanolPct":       latest_log.ethanol_pct,
                                    "setupPh":          latest_log.setup_ph,
                                    "finalPh":          latest_log.final_ph,
                                    "setupSg":          latest_log.setup_sg,
                                    "finalSg":          latest_log.final_sg,
                                    "feedingHours":     latest_log.feeding_hours,
                                    "retentionHours":   latest_log.retention_hours,
                                    "confidence":       pred_conf,
                                    "sync_time":        latest_log.date
                                }
                            }
                            q.append(f"data: {json.dumps(initial_msg)}\n\n")
            except Exception as e:
                print(f"Error yielding initial SSE state: {e}")

            self.listeners.append(q)
            try:
                while True:
                    if q:
                        yield q.pop(0)
                    time.sleep(0.5)
            except GeneratorExit:
                self.listeners.remove(q)
        return stream

    def broadcast(self, data):
        message = f"data: {json.dumps(data)}\n\n"
        for q in self.listeners:
            q.append(message)

sse_manager = SSEManager()

def run_ai_prediction(features_dict):
    """Utility to run Random Forest prediction from raw features dict."""
    if model is None:
        return "NORMAL", 0.85 # Fallback default
        
    try:
        # Extract features in the 9-dimensional vector expected by the model
        feeding_hours = float(features_dict.get('feedingHours', 0.0))
        retention_hours = float(features_dict.get('retentionHours', 0.0))
        setup_sg = float(features_dict.get('setupSg', 1.0))
        final_sg = float(features_dict.get('finalSg', 1.0))
        sg_diff = setup_sg - final_sg
        setup_alc = float(features_dict.get('setupAlc', 0.0))
        final_alc = float(features_dict.get('washAlcohol', features_dict.get('ethanolPct', 0.0))) # Maps to wash alcohol (with fallback to product alcohol)
        setup_ph = float(features_dict.get('setupPh', 4.5))
        final_ph = float(features_dict.get('finalPh', 4.5))
        
        X_input = np.array([[
            feeding_hours,
            retention_hours,
            setup_sg,
            final_sg,
            sg_diff,
            setup_alc,
            final_alc,
            setup_ph,
            final_ph
        ]])
        
        # Predict class index (0: Low Alcohol/RISK, 1: Normal, 2: Golden Batch)
        pred_idx = int(model.predict(X_input)[0])
        labels = ["RISK", "NORMAL", "GOLDEN BATCH"]
        label = labels[pred_idx]
        
        # Calculate confidence score via probability
        prob = model.predict_proba(X_input)[0]
        confidence = float(prob[pred_idx])
        
        return label, confidence
    except Exception as e:
        print(f"Error executing AI prediction: {e}")
        return "NORMAL", 0.80

@app.route('/api/v1/distillery/predict', methods=['POST'])
def get_prediction_only():
    """Predicts batch quality from preprocessed features using the Random Forest model."""
    payload = request.json
    label, confidence = run_ai_prediction(payload)
    return jsonify({
        "status": "success",
        "prediction": {
            "label": label,
            "confidence": confidence
        }
    })

@app.route('/api/v1/distillery/logs', methods=['POST'])
def add_distillery_log():
    payload = request.json
    raw_payload = payload.get('raw_data', payload) # Support nested or flat payloads
    
    # 1. Store Raw Data
    raw_log = RawDataLog(
        factory_code=payload.get('factoryCode', raw_payload.get('factoryCode', 'F01')),
        file_name=raw_payload.get('fileName', ''),
        file_url=raw_payload.get('webViewLink', ''),
        date=raw_payload.get('date', datetime.now().strftime("%Y-%m-%d")),
        fermenter=int(raw_payload.get('fermenter', 1)),
        pf=raw_payload.get('pf', 'PF-1'),
        feeding_hours=float(raw_payload.get('feedingHours', 0.0)),
        retention_hours=float(raw_payload.get('retentionHours', 0.0)),
        setup_sg=float(raw_payload.get('setupSg', 0.0)),
        final_sg=float(raw_payload.get('finalSg', 0.0)),
        setup_ph=float(raw_payload.get('setupPh', 0.0)),
        final_ph=float(raw_payload.get('finalPh', 0.0)),
        actual_production=float(raw_payload.get('actualProduction', 0.0)),
        fe_efficiency=float(raw_payload.get('feEfficiency', 0.0)),
        ethanol_pct=float(raw_payload.get('ethanolPct', 0.0))
    )
    db.session.add(raw_log)
    db.session.commit() # Commit to generate ID
    
    # 2. Store / Evaluate Prediction Data
    pred_payload = payload.get('prediction')
    if pred_payload:
        label = pred_payload.get('label', 'NORMAL')
        confidence = float(pred_payload.get('confidence', 0.85))
    else:
        # Run auto-prediction via Random Forest if not pre-calculated
        label, confidence = run_ai_prediction(raw_payload)
        
    prediction = AIPrediction(
        raw_log_id=raw_log.id,
        prediction_label=label,
        confidence_score=confidence
    )
    db.session.add(prediction)
    db.session.commit()
    
    # 3. Broadcast Event via SSE to dashboard clients
    broadcast_data = {
        "event": "new_distillery_batch",
        "data": {
            "factoryCode":      raw_log.factory_code,
            "fileName":         raw_log.file_name,
            "fileUrl":          raw_log.file_url,
            "date":             raw_log.date,
            "fermenter":        raw_log.fermenter,
            "pf":               raw_log.pf,
            "alert":            prediction.prediction_label,
            "actualProduction": raw_log.actual_production,
            "feEfficiency":     raw_log.fe_efficiency,
            "ethanolPct":       raw_log.ethanol_pct,
            "setupPh":          raw_log.setup_ph,
            "finalPh":          raw_log.final_ph,
            "setupSg":          raw_log.setup_sg,
            "finalSg":          raw_log.final_sg,
            "feedingHours":     raw_log.feeding_hours,
            "retentionHours":   raw_log.retention_hours,
            "confidence":       prediction.confidence_score,
            "sync_time":        datetime.now().strftime("%I:%M %p")
        }
    }
    sse_manager.broadcast(broadcast_data)
    
    # 4. Broadcast via MQTT to Secondary App (non-blocking)
    if mqtt_client:
        try:
            mqtt_topic = f"distillery/factory/{raw_log.factory_code}/telemetry"
            mqtt_payload = json.dumps(broadcast_data["data"])
            mqtt_client.publish(mqtt_topic, mqtt_payload)
            print(f"MQTT Broadcast published to [{mqtt_topic}]")
        except Exception as _mqtt_pub_e:
            print(f"MQTT Broadcast error: {_mqtt_pub_e}")
    
    return jsonify({"status": "success", "message": "Raw and prediction logs stored and broadcasted."})


@app.route('/api/v1/distillery/action_log', methods=['POST'])
def add_operator_action():
    try:
        data = request.json
        action = data.get('action')
        factory_code = data.get('factoryCode', 'F01')
        if not action:
            return jsonify({'error': 'Missing action field'}), 400
        
        log_entry = OperatorActionLog(action=action, factory_code=factory_code)
        db.session.add(log_entry)
        db.session.commit()
        return jsonify({'status': 'success', 'id': log_entry.id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/v1/distillery/snapshots', methods=['GET'])
def get_distillery_snapshots():
    """Returns the last 2 distillery log entries for a specific factory code."""
    try:
        factory_code = request.args.get('factory_code', 'F01')
        rows = RawDataLog.query.filter_by(factory_code=factory_code).order_by(RawDataLog.created_at.desc()).all()
        result = []
        for row in rows:
            pred = row.predictions[0] if row.predictions else None
            result.append({
                'id': row.id,
                'factoryCode': row.factory_code,
                'fileName': row.file_name,
                'fileUrl': row.file_url,
                'date': row.date,
                'fermenter': row.fermenter,
                'ethanolPct': row.ethanol_pct,
                'feEfficiency': row.fe_efficiency,
                'actualProduction': row.actual_production,
                'setupPh': row.setup_ph,
                'finalPh': row.final_ph,
                'setupSg': row.setup_sg,
                'finalSg': row.final_sg,
                'feedingHours': row.feeding_hours,
                'retentionHours': row.retention_hours,
                'createdAt': row.created_at.isoformat(),
                'predictionLabel': pred.prediction_label if pred else None,
                'confidence': pred.confidence_score if pred else None,
            })
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/v1/fermentation/stream')
def stream_events():
    return Response(sse_manager.listen()(), mimetype='text/event-stream')

@app.route('/dashboard')
def render_web_dashboard():
    return render_template('dashboard.html')

if __name__ == '__main__':
    with app.app_context():
        # Handle database migration (adding factory_code column safely to existing databases)
        db.create_all()
        # Ensure SQLite has the factory_code column by executing raw SQL just in case
        try:
            db.session.execute(db.text("ALTER TABLE raw_data_log ADD COLUMN factory_code VARCHAR(20) DEFAULT 'F01'"))
            db.session.commit()
            print("Successfully migrated database raw_data_log table to add factory_code.")
        except Exception as e:
            # If column already exists, this block will pass silently
            pass
            
    app.run(host='0.0.0.0', port=5000, debug=True)
