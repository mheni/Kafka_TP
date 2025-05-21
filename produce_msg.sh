#!/bin/bash

# Script pour produire des messages dans un topic Kafka
echo "Production de messages dans un topic Kafka"
echo "----------------------------------------"

# Vérification des arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <nom_du_topic>"
    exit 1
fi

TOPIC_NAME=$1

# Lancement du producteur console
echo "Lancement du producteur pour le topic '$TOPIC_NAME'..."
echo "Tapez vos messages ligne par ligne. Utilisez Ctrl+C pour quitter."
echo "-------------------------------------------------------------"

cd kafka_2.13-2.6.0
bin/kafka-console-producer.sh --topic $TOPIC_NAME --bootstrap-server localhost:9092
