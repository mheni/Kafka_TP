#!/bin/bash

# Script pour consommer des messages d'un topic Kafka
echo "Consommation de messages depuis un topic Kafka"
echo "--------------------------------------------"

# Vérification des arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <nom_du_topic> [groupe_de_consommateurs]"
    exit 1
fi

TOPIC_NAME=$1
GROUP_ID=""

# Vérification si un groupe de consommateurs est spécifié
if [ $# -eq 2 ]; then
    GROUP_ID="--group $2"
    echo "Consommation des messages du topic '$TOPIC_NAME' avec le groupe '$2'..."
else
    echo "Consommation des messages du topic '$TOPIC_NAME' sans groupe..."
fi

# Lancement du consommateur console
echo "Affichage des messages depuis le début. Utilisez Ctrl+C pour quitter."
echo "----------------------------------------------------------------"

cd kafka_2.13-2.6.0
bin/kafka-console-consumer.sh --topic $TOPIC_NAME --from-beginning --bootstrap-server localhost:9092 $GROUP_ID
