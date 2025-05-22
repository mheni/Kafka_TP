@echo off
REM Script d'installation de Kafka 2.6.0 sur Windows
echo Installation de Kafka 2.6.0 sur Windows

REM Vérification de Java
echo Vérification de l'installation de Java...
java -version 2>NUL
if %ERRORLEVEL% NEQ 0 (
    echo Java n'est pas installé ou n'est pas dans le PATH.
    echo Veuillez installer Java avant de continuer.
    echo Vous pouvez télécharger Java depuis https://www.oracle.com/java/technologies/javase-downloads.html
    exit /b 1
)

echo Java est correctement installé.

REM Téléchargement de Kafka
echo Téléchargement de Kafka 2.6.0...
powershell -Command "Invoke-WebRequest -Uri 'https://archive.apache.org/dist/kafka/2.6.0/kafka_2.13-2.6.0.tgz' -OutFile 'kafka_2.13-2.6.0.tgz'"

REM Vérification de 7-Zip
where 7z >NUL 2>NUL
if %ERRORLEVEL% NEQ 0 (
    echo 7-Zip n'est pas installé ou n'est pas dans le PATH.
    echo Veuillez installer 7-Zip avant de continuer.
    echo Vous pouvez télécharger 7-Zip depuis https://www.7-zip.org/
    exit /b 1
)

REM Extraction de l'archive
echo Extraction de l'archive Kafka...
7z x kafka_2.13-2.6.0.tgz
7z x kafka_2.13-2.6.0.tar

REM Création des répertoires pour les données
echo Création des répertoires pour les données...
mkdir kafka_2.13-2.6.0\zookeeper-data
mkdir kafka_2.13-2.6.0\kafka-logs

REM Modification des fichiers de configuration
echo Modification des fichiers de configuration...
powershell -Command "(Get-Content kafka_2.13-2.6.0\config\zookeeper.properties) -replace 'dataDir=/tmp/zookeeper', 'dataDir=./zookeeper-data' | Set-Content kafka_2.13-2.6.0\config\zookeeper.properties"
powershell -Command "(Get-Content kafka_2.13-2.6.0\config\server.properties) -replace 'log.dirs=/tmp/kafka-logs', 'log.dirs=./kafka-logs' | Set-Content kafka_2.13-2.6.0\config\server.properties"

echo Installation terminée avec succès!
echo.
echo Pour démarrer ZooKeeper: cd kafka_2.13-2.6.0 et exécutez bin\windows\zookeeper-server-start.bat config\zookeeper.properties
echo Pour démarrer Kafka: cd kafka_2.13-2.6.0 et exécutez bin\windows\kafka-server-start.bat config\server.properties
