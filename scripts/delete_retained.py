import time
import paho.mqtt.client as mqtt

def delete_retained():
    # Use TCP 1883 — clearing retained via TCP clears them for all transports
    # (retained messages are stored broker-side, transport doesn't matter)
    client = mqtt.Client(
        client_id="delete_retained_script",
        callback_api_version=mqtt.CallbackAPIVersion.VERSION2
    )
    
    print("Connecting to broker.hivemq.com on port 1883 (TCP)...")
    client.connect("broker.hivemq.com", 1883, 60)
    client.loop_start()
    
    # Wait for connection to stabilise
    time.sleep(2.0)
    
    factories = ["F01", "F02", "F03", "F04", "F05"]
    for f in factories:
        topic = f"distillery/factory/{f}/telemetry"
        print(f"Clearing retained message on [{topic}] ...")
        # Publishing a zero-byte payload with retain=True deletes the retained message from the broker
        result = client.publish(topic, payload=b"", qos=1, retain=True)
        result.wait_for_publish()
        print(f"  -> Cleared [{topic}]")
        time.sleep(0.3)
        
    print("\nAll retained messages cleared.")
    time.sleep(1.0)
    client.loop_stop()
    client.disconnect()
    print("Done!")

if __name__ == "__main__":
    delete_retained()
