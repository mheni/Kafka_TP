# Travaux Pratique Kafka – Données Banque Mondiale

**Sujet** : Collecte et traitement des données de population (France) depuis l’API de la Banque Mondiale avec Apache Kafka.

## 🧰 Prérequis

- Python 3.x
- Apache Kafka (Zookeeper + Broker démarrés)
- `kafka-python` : `pip install kafka-python`
- Kafka CLI accessible (`kafka-topics.sh`, `kafka-console-consumer.sh`, etc.)

## Étape 1 – Comprendre les données source

L’API suivante retourne la population totale de la France sur plusieurs années :

```bash
http://api.worldbank.org/v2/country/fr/indicator/SP.POP.TOTL?format=json
```

## Étape 2 – Créer un topic Kafka

```bash
$ kafka-topics.sh --create --topic worldbank-population \
  --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
```

Vérification :

```bash
$ kafka-topics.sh --list --bootstrap-server localhost:9092
```

## Étape 3 – Écrire le producteur Kafka en Python

Créer le fichier `producer_worldbank.py` :

```python
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
            print(f"Produced {len(data[1])} records to topic 	'{topic}	'")
    except Exception as e:
        print("Error:", e)

    time.sleep(3600)  # toutes les heures
```

Exécutez-le :

```bash
$ python3 producer_worldbank.py
```

## Étape 4 – Lire les données avec un Consumer CLI

```bash
$ kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic worldbank-population \
  --from-beginning \
  --property print.key=true \
  --property key.separator=" : "
```

## Étape 5 – Écrire un Consumer Python

Créer `consumer_worldbank.py` :

```python
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
```

Lancer avec :

```bash
$ python3 consumer_worldbank.py
```

## ✅ Résultat attendu

Vous verrez s'afficher dans le terminal :

```python-repl
Année 2022 : 68042591 habitants  
Année 2021 : 67896159 habitants  
...
```

## 📌 Extensions possibles

- Écrire les données dans une base PostgreSQL, MongoDB ou ElasticSearch
- Streamer dans Spark/Flink pour des analyses temps réel
- Créer un dashboard Grafana ou Superset via Kafka Connect
