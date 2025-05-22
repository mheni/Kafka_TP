@echo off
REM Script pour produire des messages dans un topic Kafka sur Windows

echo Production de messages dans un topic Kafka
echo ----------------------------------------

REM Vérification des arguments
if "%~1"=="" (
    echo Usage: %0 ^<nom_du_topic^>
    exit /b 1
)

set TOPIC_NAME=%1

REM Lancement du producteur console
echo Lancement du producteur pour le topic '%TOPIC_NAME%'...
echo Tapez vos messages ligne par ligne. Utilisez Ctrl+C pour quitter.
echo -------------------------------------------------------------

cd kafka_2.13-2.6.0
bin\windows\kafka-console-producer.bat --topic %TOPIC_NAME% --bootstrap-server localhost:9092
