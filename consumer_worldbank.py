from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'worldbank-population',
    bootstrap_servers='localhost:9092',
    auto_offset_reset='earliest',
    enable_auto_commit=True,
    key_deserializer=lambda k: k.decode('utf-8'),
    value_deserializer=lambda v: json.loads(v.decode('utf-8'))
)

for message in consumer:
    print(f"Année {message.key} : {message.value['population']} habitants")
