# Travaux Pratiques : Apache Kafka sur Ubuntu

Ce TP vous guidera à travers l'installation et l'utilisation d'Apache Kafka 2.6 sur Ubuntu. Vous apprendrez à configurer Kafka et ZooKeeper, puis à effectuer des opérations fondamentales comme la création de topics, la production et la consommation de messages.

## Prérequis

- Ubuntu (version 18.04 ou supérieure)
- Java 8 ou supérieur
- Accès à un terminal
- Connexion Internet

## 1. Installation de Java

Kafka nécessite Java pour fonctionner. Commençons par vérifier si Java est déjà installé :

```bash
java -version
```

Si Java n'est pas installé, installez-le avec la commande suivante :

```bash
sudo apt update
sudo apt install -y openjdk-8-jdk
```

Vérifiez l'installation :

```bash
java -version
```

## 2. Téléchargement et Installation de Kafka 2.6

### 2.1 Téléchargement de Kafka

```bash
wget https://archive.apache.org/dist/kafka/2.6.0/kafka_2.13-2.6.0.tgz
```

### 2.2 Extraction de l'archive

```bash
tar -xzf kafka_2.13-2.6.0.tgz
cd kafka_2.13-2.6.0
```

## 3. Démarrage de ZooKeeper

Kafka utilise ZooKeeper pour la gestion de son cluster. Avant de démarrer Kafka, nous devons lancer ZooKeeper.

### 3.1 Configuration de ZooKeeper

Par défaut, ZooKeeper utilise le fichier `config/zookeeper.properties`. Examinons ce fichier :

```bash
cat config/zookeeper.properties
```

Vous devriez voir quelque chose comme :
```
dataDir=/tmp/zookeeper
clientPort=2181
maxClientCnxns=0
```

### 3.2 Démarrage du serveur ZooKeeper

```bash
bin/zookeeper-server-start.sh config/zookeeper.properties
```

Gardez cette fenêtre de terminal ouverte et lancez un nouveau terminal pour les étapes suivantes.

## 4. Démarrage du serveur Kafka

### 4.1 Configuration de Kafka

Examinons le fichier de configuration par défaut de Kafka :

```bash
cat config/server.properties
```

Notez les paramètres importants comme :
- `broker.id=0`
- `listeners=PLAINTEXT://:9092`
- `log.dirs=/tmp/kafka-logs`

### 4.2 Démarrage du serveur Kafka

```bash
bin/kafka-server-start.sh config/server.properties
```

Gardez cette fenêtre de terminal ouverte et lancez un nouveau terminal pour les étapes suivantes.

## 5. Opérations de base avec Kafka

### 5.1 Création d'un topic

Créons un topic nommé "test" avec 1 partition et un facteur de réplication de 1 :

```bash
bin/kafka-topics.sh --create --topic test --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
```

### 5.2 Liste des topics

Vérifions que notre topic a bien été créé :

```bash
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

### 5.3 Détails d'un topic

Examinons les détails de notre topic "test" :

```bash
bin/kafka-topics.sh --describe --topic test --bootstrap-server localhost:9092
```

## 6. Production et Consommation de messages

### 6.1 Production de messages

Lançons un producteur pour envoyer des messages au topic "test" :

```bash
bin/kafka-console-producer.sh --topic test --bootstrap-server localhost:9092
```

Tapez quelques messages, par exemple :
```
Bonjour Kafka
Ceci est un message de test
Kafka est un système de messagerie distribué
```

Appuyez sur Ctrl+C pour quitter le producteur.

### 6.2 Consommation de messages

Dans un nouveau terminal, lançons un consommateur pour lire les messages du topic "test" :

```bash
bin/kafka-console-consumer.sh --topic test --from-beginning --bootstrap-server localhost:9092
```

Vous devriez voir les messages que vous avez envoyés précédemment.

## 7. Manipulations avancées

### 7.1 Création d'un topic avec plusieurs partitions

Créons un nouveau topic avec plusieurs partitions :

```bash
bin/kafka-topics.sh --create --topic multi-partitions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
```

### 7.2 Utilisation de groupes de consommateurs

Ouvrez deux terminaux et lancez deux consommateurs appartenant au même groupe :

Terminal 1 :
```bash
bin/kafka-console-consumer.sh --topic multi-partitions --bootstrap-server localhost:9092 --group groupe1
```

Terminal 2 :
```bash
bin/kafka-console-consumer.sh --topic multi-partitions --bootstrap-server localhost:9092 --group groupe1
```

Dans un troisième terminal, envoyez des messages au topic :
```bash
bin/kafka-console-producer.sh --topic multi-partitions --bootstrap-server localhost:9092
```

Observez comment les messages sont répartis entre les deux consommateurs du même groupe.

### 7.3 Liste des groupes de consommateurs

```bash
bin/kafka-consumer-groups.sh --list --bootstrap-server localhost:9092
```

### 7.4 Détails d'un groupe de consommateurs

```bash
bin/kafka-consumer-groups.sh --describe --group groupe1 --bootstrap-server localhost:9092
```

## 8. Nettoyage

Pour arrêter proprement Kafka et ZooKeeper :

```bash
bin/kafka-server-stop.sh
bin/zookeeper-server-stop.sh
```

Pour supprimer les données temporaires :
```bash
rm -rf /tmp/kafka-logs /tmp/zookeeper
```

## Conclusion

Félicitations ! Vous avez réussi à :
- Installer Kafka 2.6 sur Ubuntu
- Configurer et démarrer ZooKeeper
- Démarrer un serveur Kafka
- Créer des topics
- Produire et consommer des messages
- Utiliser des groupes de consommateurs
- Explorer les commandes d'administration de Kafka

Ces compétences constituent la base pour travailler avec Kafka dans des environnements de production.
