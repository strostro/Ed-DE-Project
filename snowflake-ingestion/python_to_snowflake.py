import json
from kafka import KafkaConsumer
import snowflake.connector

# ====== Initialize Kafka Consumer ======
consumer = KafkaConsumer(
    'learning-events',
    bootstrap_servers='3.25.71.43:9092',
    value_deserializer=lambda m: json.loads(m.decode('utf-8')),
    auto_offset_reset='earliest',
    enable_auto_commit=False,
    consumer_timeout_ms=10000  # Stop if no new messages for 10 seconds
)

# ====== Connect to Snowflake ======
conn = snowflake.connector.connect(
    user='your_username',
    password='your_password',   # 🔒 Replace with secure method (e.g., environment variable)
    account='your_account',
    warehouse='COMPUTE_WH',
    database='KAFKA_DEMO',
    schema='PUBLIC',
)
cursor = conn.cursor()

# ====== Insert function: write to raw table ======
def insert_into_snowflake(event):
    sql = """
        INSERT INTO raw_learning_events_v2 (event_id, event_type, timestamp, raw_payload)
        SELECT %s, %s, %s, PARSE_JSON(%s)
    """
    data = (
        event.get("event_id"),
        event.get("event_type"),
        event.get("timestamp"),
        json.dumps(event)  # Must stringify JSON before sending
    )
    cursor.execute(sql, data)

# ====== Consume and write loop ======
print("🚀 Start consuming messages from Kafka...")

counter = 0
for msg in consumer:
    event = msg.value
    print(f"📥 Received event: {event['event_id']} - {event['event_type']}")
    insert_into_snowflake(event)
    counter += 1

    if counter % 100 == 0:
        conn.commit()
        print("💾 Batch committed!")

# Commit any remaining events
conn.commit()
print("✅ All data committed!")

# ====== Clean up connections ======
cursor.close()
conn.close()
