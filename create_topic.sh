#!/bin/bash

# Script pour créer un topic Kafka
echo "Création d'un topic Kafka"
echo "------------------------"

# Vérification des arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <nom_du_topic>"
    exit 1
fi

TOPIC_NAME=$1

# Création du topic
echo "Création du topic '$TOPIC_NAME'..."
cd kafka_2.13-2.6.0
bin/kafka-topics.sh --create --topic $TOPIC_NAME --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

# Affichage des détails du topic
echo "Détails du topic '$TOPIC_NAME':"
bin/kafka-topics.sh --describe --topic $TOPIC_NAME --bootstrap-server localhost:9092

echo "Topic '$TOPIC_NAME' créé avec succès!"
