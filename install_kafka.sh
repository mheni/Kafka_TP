#!/bin/bash

# Script d'installation de Kafka 2.6.0 sur Ubuntu
echo "Installation de Kafka 2.6.0 sur Ubuntu"

# Vérification de Java
echo "Vérification de l'installation de Java..."
if type -p java; then
    echo "Java est déjà installé"
    java -version
else
    echo "Installation de Java..."
    sudo apt update
    sudo apt install -y openjdk-8-jdk
    echo "Java installé avec succès"
    java -version
fi

# Téléchargement de Kafka
echo "Téléchargement de Kafka 2.6.0..."
wget https://archive.apache.org/dist/kafka/2.6.0/kafka_2.13-2.6.0.tgz

# Extraction de l'archive
echo "Extraction de l'archive Kafka..."
tar -xzf kafka_2.13-2.6.0.tgz

echo "Installation terminée avec succès!"
echo "Pour démarrer ZooKeeper: cd kafka_2.13-2.6.0 && bin/zookeeper-server-start.sh config/zookeeper.properties"
echo "Pour démarrer Kafka: cd kafka_2.13-2.6.0 && bin/kafka-server-start.sh config/server.properties"
