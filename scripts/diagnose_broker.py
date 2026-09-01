import paho.mqtt.client as mqtt
import time
import json

RECEIVED = {}

def on_connect(client, userdata, flags, rc):
    print(f"[TEST] Connected to broker (rc={rc})")
    client.subscribe("distillery/factory/+/telemetry")

def on_message(client, userdata, msg):
    try:
        data = json.loads(msg.payload.decode('utf-8'))
        f_code = data.get('factoryCode')
        RECEIVED[f_code] = data
        print(f"  -> RECEIVED {msg.topic}: {f_code} | Excel: {data.get('fileName')} | Alert: {data.get('alert')} | Retain: {msg.retain}")
    except Exception as e:
        print(f"  -> Parse Error on {msg.topic}: {e}")

# Step 1: Connect and inspect current topics
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

print("--- Testing broker.hivemq.com:1883 ---")
client.connect("broker.hivemq.com", 1883, 60)
client.loop_start()
time.sleep(3)

print(f"\nCurrently retained factories on broker: {list(RECEIVED.keys())}")
client.loop_stop()
client.disconnect()
