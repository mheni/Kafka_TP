# Travaux Pratiques : Apache Kafka sur Windows

Ce TP vous guidera à travers l'installation et l'utilisation d'Apache Kafka 2.6 sur Windows. Vous apprendrez à configurer Kafka et ZooKeeper, puis à effectuer des opérations fondamentales comme la création de topics, la production et la consommation de messages.

## Prérequis

- Windows 10 ou Windows 11
- Java 8 ou supérieur
- Accès à un terminal PowerShell ou Command Prompt
- Connexion Internet

## 1. Installation de Java

Kafka nécessite Java pour fonctionner. Commençons par vérifier si Java est déjà installé :

```powershell
java -version
```

Si Java n'est pas installé, suivez ces étapes :

1. Téléchargez Java JDK depuis le site officiel d'Oracle ou utilisez OpenJDK
2. Exécutez le programme d'installation et suivez les instructions
3. Configurez les variables d'environnement :
   - Créez une variable système `JAVA_HOME` pointant vers le répertoire d'installation de Java (ex: `C:\Program Files\Java\jdk1.8.0_xxx`)
   - Ajoutez `%JAVA_HOME%\bin` à la variable `Path`

Vérifiez l'installation :

```powershell
java -version
```

## 2. Téléchargement et Installation de Kafka 2.6

### 2.1 Téléchargement de Kafka

1. Téléchargez Kafka 2.6.0 depuis le site d'Apache :
   ```powershell
   Invoke-WebRequest -Uri "https://archive.apache.org/dist/kafka/2.6.0/kafka_2.13-2.6.0.tgz" -OutFile "kafka_2.13-2.6.0.tgz"
   ```

2. Si vous n'avez pas 7-Zip ou un utilitaire similaire, installez-le :
   ```powershell
   # Avec chocolatey (si installé)
   choco install 7zip -y
   
   # Ou téléchargez manuellement depuis https://www.7-zip.org/
   ```

### 2.2 Extraction de l'archive

1. Extrayez l'archive téléchargée :
   ```powershell
   # Avec 7-Zip
   & 'C:\Program Files\7-Zip\7z.exe' x kafka_2.13-2.6.0.tgz
   & 'C:\Program Files\7-Zip\7z.exe' x kafka_2.13-2.6.0.tar
   ```

2. Déplacez le dossier extrait vers un emplacement permanent (par exemple, `C:\kafka_2.13-2.6.0`)

## 3. Configuration de Kafka pour Windows

### 3.1 Modification des scripts pour Windows

Par défaut, Kafka utilise des scripts shell Unix. Pour Windows, nous devons utiliser les scripts batch (.bat) fournis.

### 3.2 Configuration de ZooKeeper

1. Ouvrez le fichier `config\zookeeper.properties` dans un éditeur de texte
2. Modifiez le chemin `dataDir` pour utiliser un format Windows :
   ```
   dataDir=C:/kafka_2.13-2.6.0/zookeeper-data
   ```
3. Créez le dossier spécifié :
   ```powershell
   mkdir C:\kafka_2.13-2.6.0\zookeeper-data
   ```

### 3.3 Configuration de Kafka

1. Ouvrez le fichier `config\server.properties` dans un éditeur de texte
2. Modifiez le chemin `log.dirs` pour utiliser un format Windows :
   ```
   log.dirs=C:/kafka_2.13-2.6.0/kafka-logs
   ```
3. Créez le dossier spécifié :
   ```powershell
   mkdir C:\kafka_2.13-2.6.0\kafka-logs
   ```

## 4. Démarrage de ZooKeeper

Ouvrez une fenêtre PowerShell et naviguez vers le répertoire Kafka :

```powershell
cd C:\kafka_2.13-2.6.0
```

Démarrez ZooKeeper :

```powershell
.\bin\windows\zookeeper-server-start.bat .\config\zookeeper.properties
```

Gardez cette fenêtre PowerShell ouverte et lancez une nouvelle fenêtre pour les étapes suivantes.

## 5. Démarrage du serveur Kafka

Dans une nouvelle fenêtre PowerShell, naviguez vers le répertoire Kafka :

```powershell
cd C:\kafka_2.13-2.6.0
```

Démarrez le serveur Kafka :

```powershell
.\bin\windows\kafka-server-start.bat .\config\server.properties
```

Gardez cette fenêtre PowerShell ouverte et lancez une nouvelle fenêtre pour les étapes suivantes.

## 6. Opérations de base avec Kafka

### 6.1 Création d'un topic

Dans une nouvelle fenêtre PowerShell, naviguez vers le répertoire Kafka :

```powershell
cd C:\kafka_2.13-2.6.0
```

Créez un topic nommé "test" avec 1 partition et un facteur de réplication de 1 :

```powershell
.\bin\windows\kafka-topics.bat --create --topic test --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
```

### 6.2 Liste des topics

Vérifiez que votre topic a bien été créé :

```powershell
.\bin\windows\kafka-topics.bat --list --bootstrap-server localhost:9092
```

### 6.3 Détails d'un topic

Examinez les détails de votre topic "test" :

```powershell
.\bin\windows\kafka-topics.bat --describe --topic test --bootstrap-server localhost:9092
```

## 7. Production et Consommation de messages

### 7.1 Production de messages

Dans une nouvelle fenêtre PowerShell, lancez un producteur pour envoyer des messages au topic "test" :

```powershell
.\bin\windows\kafka-console-producer.bat --topic test --bootstrap-server localhost:9092
```

Tapez quelques messages, par exemple :
```
Bonjour Kafka
Ceci est un message de test
Kafka est un système de messagerie distribué
```

Appuyez sur Ctrl+C pour quitter le producteur.

### 7.2 Consommation de messages

Dans une nouvelle fenêtre PowerShell, lancez un consommateur pour lire les messages du topic "test" :

```powershell
.\bin\windows\kafka-console-consumer.bat --topic test --from-beginning --bootstrap-server localhost:9092
```

Vous devriez voir les messages que vous avez envoyés précédemment.

## 8. Manipulations avancées

### 8.1 Création d'un topic avec plusieurs partitions

Créez un nouveau topic avec plusieurs partitions :

```powershell
.\bin\windows\kafka-topics.bat --create --topic multi-partitions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
```

### 8.2 Utilisation de groupes de consommateurs

Ouvrez deux fenêtres PowerShell et lancez deux consommateurs appartenant au même groupe :

Fenêtre PowerShell 1 :
```powershell
.\bin\windows\kafka-console-consumer.bat --topic multi-partitions --bootstrap-server localhost:9092 --group groupe1
```

Fenêtre PowerShell 2 :
```powershell
.\bin\windows\kafka-console-consumer.bat --topic multi-partitions --bootstrap-server localhost:9092 --group groupe1
```

Dans une troisième fenêtre PowerShell, envoyez des messages au topic :
```powershell
.\bin\windows\kafka-console-producer.bat --topic multi-partitions --bootstrap-server localhost:9092
```

Observez comment les messages sont répartis entre les deux consommateurs du même groupe.

### 8.3 Liste des groupes de consommateurs

```powershell
.\bin\windows\kafka-consumer-groups.bat --list --bootstrap-server localhost:9092
```

### 8.4 Détails d'un groupe de consommateurs

```powershell
.\bin\windows\kafka-consumer-groups.bat --describe --group groupe1 --bootstrap-server localhost:9092
```

## 9. Nettoyage

Pour arrêter proprement Kafka et ZooKeeper :

1. Arrêtez le serveur Kafka en appuyant sur Ctrl+C dans la fenêtre PowerShell correspondante
2. Arrêtez ZooKeeper en appuyant sur Ctrl+C dans la fenêtre PowerShell correspondante

Pour supprimer les données temporaires :
```powershell
Remove-Item -Recurse -Force C:\kafka_2.13-2.6.0\kafka-logs
Remove-Item -Recurse -Force C:\kafka_2.13-2.6.0\zookeeper-data
```

## 10. Résolution des problèmes courants sur Windows

### 10.1 Problèmes de chemin

Si vous rencontrez des erreurs liées aux chemins, assurez-vous d'utiliser des barres obliques (/) dans les fichiers de configuration, même sous Windows.

### 10.2 Problèmes de port

Si les ports 2181 (ZooKeeper) ou 9092 (Kafka) sont déjà utilisés :
1. Identifiez le processus utilisant le port :
   ```powershell
   netstat -ano | findstr :2181
   netstat -ano | findstr :9092
   ```
2. Terminez le processus ou modifiez les ports dans les fichiers de configuration

### 10.3 Problèmes de mémoire

Si vous rencontrez des erreurs de mémoire insuffisante, modifiez les fichiers batch pour allouer moins de mémoire :
1. Ouvrez `bin\windows\kafka-server-start.bat`
2. Modifiez la ligne contenant `-Xmx1G -Xms1G` pour réduire l'allocation de mémoire, par exemple `-Xmx512M -Xms512M`

## Conclusion

Félicitations ! Vous avez réussi à :
- Installer Kafka 2.6 sur Windows
- Configurer et démarrer ZooKeeper
- Démarrer un serveur Kafka
- Créer des topics
- Produire et consommer des messages
- Utiliser des groupes de consommateurs
- Explorer les commandes d'administration de Kafka

Ces compétences constituent la base pour travailler avec Kafka dans des environnements de production Windows.
