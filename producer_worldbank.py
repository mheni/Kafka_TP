#!/usr/bin/env python3
import json
import time
import urllib.request
from kafka import KafkaProducer

url = "http://api.worldbank.org/v2/country/fr/indicator/SP.POP.TOTL?format=json"
topic = "worldbank-population"

producer = KafkaProducer(
    bootstrap_servers="localhost:9092",
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    key_serializer=lambda k: str(k).encode("utf-8")
)

while True:
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())

            if len(data) < 2:
                print("No data found.")
                continue

            for record in data[1]:
                if record["value"] is not None:
                    value = {
                        "country": record["country"]["value"],
                        "indicator": record["indicator"]["value"],
                        "year": record["date"],
                        "population": record["value"]
                    }
                    key = record["date"]
                    producer.send(topic, key=key, value=value)
            print(f"Produced {len(data[1])} records to topic '{topic}'")
    except Exception as e:
        print("Error:", e)

    time.sleep(3600)
