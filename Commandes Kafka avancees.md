# Commandes Kafka avancées : Clés, Consommateurs et Accusés de réception

Ce document présente les commandes Kafka avancées organisées en cinq sections distinctes, avec des explications et des exemples pour chaque concept.

## 1. Producteur avec clé (Producer with key)

Les clés dans Kafka permettent un partitionnement déterministe des messages. Tous les messages ayant la même clé sont envoyés à la même partition, garantissant ainsi l'ordre de traitement pour une clé donnée.

### Sous Linux/Ubuntu

```bash
# Format de base : clé:valeur
bin/kafka-console-producer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --property "parse.key=true" \
  --property "key.separator=:"
```

### Sous Windows

```powershell
# Format de base : clé:valeur
.\bin\windows\kafka-console-producer.bat --topic nom_topic --bootstrap-server localhost:9092 ^
  --property "parse.key=true" ^
  --property "key.separator=:"
```

### Exemple d'utilisation

```
utilisateur1:Message pour l'utilisateur 1
utilisateur2:Message pour l'utilisateur 2
utilisateur1:Autre message pour l'utilisateur 1
```

Les messages avec la clé "utilisateur1" iront toujours dans la même partition, préservant leur ordre relatif.

## 2. Consommateur (Consumer)

Le consommateur Kafka permet de lire les messages d'un topic. Pour afficher les clés des messages lors de la consommation, utilisez les propriétés appropriées.

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

L'option `--from-beginning` permet de lire tous les messages depuis le début du topic, pas seulement les nouveaux messages.

## 3. Groupe de consommateurs (Consumer Group)

Les groupes de consommateurs permettent de répartir la charge de traitement des messages entre plusieurs instances. Chaque partition d'un topic est lue par un seul consommateur au sein d'un groupe.

### Sous Linux/Ubuntu

```bash
# Consommateur 1 du groupe
bin/kafka-console-consumer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --group mon_groupe \
  --property "print.key=true" \
  --property "key.separator=:"

# Consommateur 2 du même groupe
bin/kafka-console-consumer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --group mon_groupe \
  --property "print.key=true" \
  --property "key.separator=:"
```

### Sous Windows

```powershell
# Consommateur 1 du groupe
.\bin\windows\kafka-console-consumer.bat --topic nom_topic --bootstrap-server localhost:9092 ^
  --group mon_groupe ^
  --property "print.key=true" ^
  --property "key.separator=:"

# Consommateur 2 du même groupe
.\bin\windows\kafka-console-consumer.bat --topic nom_topic --bootstrap-server localhost:9092 ^
  --group mon_groupe ^
  --property "print.key=true" ^
  --property "key.separator=:"
```

### Liste et description des groupes de consommateurs

```bash
# Liste des groupes
bin/kafka-consumer-groups.sh --list --bootstrap-server localhost:9092

# Détails d'un groupe spécifique
bin/kafka-consumer-groups.sh --describe --group mon_groupe --bootstrap-server localhost:9092
```

## 4. Niveaux d'accusé de réception (ack=0, ack=1, ack=all)

Les niveaux d'accusé de réception déterminent la fiabilité de la livraison des messages.

### ack=0 (Aucune confirmation)

Le producteur n'attend aucune confirmation du broker. Offre la performance maximale mais la fiabilité minimale (risque de perte de messages).

```bash
bin/kafka-console-producer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --property "acks=0"
```

### ack=1 (Confirmation du leader uniquement)

Le producteur attend la confirmation du broker leader uniquement. Équilibre entre performance et fiabilité.

```bash
bin/kafka-console-producer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --property "acks=1"
```

### ack=all (ou ack=-1, Confirmation de tous les réplicas)

Le producteur attend la confirmation du leader et de tous les réplicas synchronisés. Offre la fiabilité maximale mais la performance la plus faible.

```bash
bin/kafka-console-producer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --property "acks=all"
```

### Combinaison avec des clés

```bash
bin/kafka-console-producer.sh --topic nom_topic --bootstrap-server localhost:9092 \
  --property "parse.key=true" \
  --property "key.separator=:" \
  --property "acks=all"
```

## 5. Committed Offset

Le "committed offset" est la position jusqu'à laquelle un groupe de consommateurs a confirmé avoir traité les messages. Cette fonctionnalité est essentielle pour la reprise après panne.

### Afficher les offsets commis

```bash
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group mon_groupe
```

La sortie affichera pour chaque partition :
- CURRENT-OFFSET : Position actuelle du consommateur
- LOG-END-OFFSET : Dernier offset disponible dans la partition
- LAG : Différence entre les deux (messages non encore consommés)

### Réinitialiser les offsets commis

```bash
# Réinitialiser à l'offset le plus ancien
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --group mon_groupe --topic nom_topic \
  --reset-offsets --to-earliest --execute

# Réinitialiser à l'offset le plus récent
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --group mon_groupe --topic nom_topic \
  --reset-offsets --to-latest --execute

# Réinitialiser à un offset spécifique
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --group mon_groupe --topic nom_topic \
  --reset-offsets --to-offset 10 --execute
```

### Auto-commit vs Commit manuel

Par défaut, les consommateurs Kafka utilisent l'auto-commit. Pour un contrôle plus précis, vous pouvez désactiver l'auto-commit et gérer manuellement les commits dans votre application.

```java
// Exemple en Java
Properties props = new Properties();
props.put("enable.auto.commit", "false");
// ...
consumer.subscribe(Collections.singletonList("nom_topic"));
// ...
// Après traitement des messages
consumer.commitSync();
```

## Exemples de scripts complets

### Script Linux pour producteur avec clé et ack=all

```bash
#!/bin/bash
# Usage: ./produce_with_key_ack.sh nom_topic
TOPIC_NAME=$1
cd kafka_2.13-2.6.0
bin/kafka-console-producer.sh --topic $TOPIC_NAME --bootstrap-server localhost:9092 \
  --property "parse.key=true" \
  --property "key.separator=:" \
  --property "acks=all"
```

### Script Windows pour consommateur avec groupe

```batch
@echo off
REM Usage: consume_with_group.bat nom_topic nom_groupe
set TOPIC_NAME=%1
set GROUP_NAME=%2
cd kafka_2.13-2.6.0
bin\windows\kafka-console-consumer.bat --topic %TOPIC_NAME% --bootstrap-server localhost:9092 ^
  --group %GROUP_NAME% ^
  --property "print.key=true" ^
  --property "key.separator=:"
```

Ces commandes et concepts sont essentiels pour développer des applications Kafka robustes et performantes en production.
