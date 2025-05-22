# Commandes Kafka pour produire des messages avec clé et accusé de réception (ack)

Ce document explique comment utiliser les producteurs Kafka avec des clés et différents niveaux d'accusé de réception (ack), deux fonctionnalités essentielles pour les applications de production.

## Importance des clés dans Kafka

Dans Kafka, les clés servent à deux objectifs principaux :

1. **Partitionnement déterministe** : Les messages ayant la même clé sont toujours envoyés à la même partition, ce qui garantit l'ordre des messages pour une clé donnée.
2. **Traitement logique** : Les clés permettent de regrouper logiquement les messages (par exemple, tous les événements concernant un utilisateur spécifique).

## Niveaux d'accusé de réception (ack)

Kafka propose trois niveaux d'accusé de réception :

1. **acks=0** : Le producteur n'attend aucune confirmation (performance maximale, fiabilité minimale)
2. **acks=1** : Le producteur attend la confirmation du leader uniquement (équilibre entre performance et fiabilité)
3. **acks=all** (ou **acks=-1**) : Le producteur attend la confirmation du leader et de tous les réplicas (fiabilité maximale, performance réduite)

## Commandes pour le producteur console avec clé

### Sous Linux/Ubuntu

```bash
# Format de base : clé:valeur
bin/kafka-console-producer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --property "parse.key=true" \
  --property "key.separator=:" \
  --property "acks=all"
```

Exemple d'utilisation :
```
utilisateur1:Message pour l'utilisateur 1
utilisateur2:Message pour l'utilisateur 2
utilisateur1:Autre message pour l'utilisateur 1
```

### Sous Windows

```powershell
# Format de base : clé:valeur
.\bin\windows\kafka-console-producer.bat --topic nom_topic --bootstrap-server localhost:9092 ^
  --property "parse.key=true" ^
  --property "key.separator=:" ^
  --property "acks=all"
```

## Consommation de messages avec affichage des clés

### Sous Linux/Ubuntu

```bash
bin/kafka-console-consumer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --property "print.key=true" \
  --property "key.separator=:" \
  --from-beginning
```

### Sous Windows

```powershell
.\bin\windows\kafka-console-consumer.bat --topic nom_topic --bootstrap-server localhost:9092 ^
  --property "print.key=true" ^
  --property "key.separator=:" ^
  --from-beginning
```

## Exemples de scripts pour produire avec clé et ack

### Script Linux/Ubuntu (produce_with_key_ack.sh)

```bash
#!/bin/bash

# Script pour produire des messages avec clé et accusé de réception
echo "Production de messages avec clé et accusé de réception"
echo "-----------------------------------------------------"

# Vérification des arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <nom_du_topic>"
    exit 1
fi

TOPIC_NAME=$1

# Lancement du producteur console avec clé et ack=all
echo "Lancement du producteur pour le topic '$TOPIC_NAME' avec clé et ack=all..."
echo "Format: clé:valeur (exemple: utilisateur1:message)"
echo "-------------------------------------------------------------"

cd kafka_2.13-2.6.0
bin/kafka-console-producer.sh --topic $TOPIC_NAME --bootstrap-server localhost:9092 \
  --property "parse.key=true" \
  --property "key.separator=:" \
  --property "acks=all"
```

### Script Windows (produce_with_key_ack.bat)

```batch
@echo off
REM Script pour produire des messages avec clé et accusé de réception sur Windows

echo Production de messages avec clé et accusé de réception
echo -----------------------------------------------------

REM Vérification des arguments
if "%~1"=="" (
    echo Usage: %0 ^<nom_du_topic^>
    exit /b 1
)

set TOPIC_NAME=%1

REM Lancement du producteur console avec clé et ack=all
echo Lancement du producteur pour le topic '%TOPIC_NAME%' avec clé et ack=all...
echo Format: clé:valeur (exemple: utilisateur1:message)
echo -------------------------------------------------------------

cd kafka_2.13-2.6.0
bin\windows\kafka-console-producer.bat --topic %TOPIC_NAME% --bootstrap-server localhost:9092 ^
  --property "parse.key=true" ^
  --property "key.separator=:" ^
  --property "acks=all"
```

## Utilisation avancée avec d'autres propriétés

Vous pouvez combiner les propriétés de clé et d'ack avec d'autres paramètres :

```bash
# Exemple avec compression et délai de regroupement
bin/kafka-console-producer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --property "parse.key=true" \
  --property "key.separator=:" \
  --property "acks=all" \
  --property "compression.type=snappy" \
  --property "linger.ms=100"
```

## Importance dans les applications de production

L'utilisation des clés et des accusés de réception est cruciale pour :

1. **Garantir l'ordre des messages** : Les messages avec la même clé sont traités dans l'ordre
2. **Assurer la durabilité des données** : Les niveaux d'ack élevés garantissent que les données sont bien répliquées
3. **Optimiser les performances** : Le choix du niveau d'ack permet d'équilibrer fiabilité et performance

Ces fonctionnalités sont essentielles pour les applications critiques où la perte de données ou le désordre des messages n'est pas acceptable.
