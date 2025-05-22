@echo off
REM Script pour consommer des messages d'un topic Kafka sur Windows

echo Consommation de messages depuis un topic Kafka
echo --------------------------------------------

REM Vérification des arguments
if "%~1"=="" (
    echo Usage: %0 ^<nom_du_topic^> [groupe_de_consommateurs]
    exit /b 1
)

set TOPIC_NAME=%1
set GROUP_ID=

REM Vérification si un groupe de consommateurs est spécifié
if not "%~2"=="" (
    set GROUP_ID=--group %2
    echo Consommation des messages du topic '%TOPIC_NAME%' avec le groupe '%2'...
) else (
    echo Consommation des messages du topic '%TOPIC_NAME%' sans groupe...
)

REM Lancement du consommateur console
echo Affichage des messages depuis le début. Utilisez Ctrl+C pour quitter.
echo ----------------------------------------------------------------

cd kafka_2.13-2.6.0
bin\windows\kafka-console-consumer.bat --topic %TOPIC_NAME% --from-beginning --bootstrap-server localhost:9092 %GROUP_ID%
