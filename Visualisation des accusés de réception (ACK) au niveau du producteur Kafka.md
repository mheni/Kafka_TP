# Visualisation des accusés de réception (ACK) au niveau du producteur Kafka

Ce document explique comment visualiser et gérer les accusés de réception (ACK) côté producteur dans Kafka, une fonctionnalité essentielle pour garantir la fiabilité des systèmes de messagerie.

## Limitations du producteur console

Le producteur console de Kafka (`kafka-console-producer.sh` ou `kafka-console-producer.bat`) ne permet pas de visualiser directement les accusés de réception. Bien que vous puissiez configurer le niveau d'ACK avec `--property "acks=all"`, vous ne verrez pas de confirmation explicite pour chaque message envoyé.

## Visualisation des ACKs avec l'API Java

Pour visualiser les ACKs, vous devez utiliser l'API Kafka en Java avec des callbacks. Voici un exemple complet :

```java
import org.apache.kafka.clients.producer.*;
import java.util.Properties;
import java.util.concurrent.ExecutionException;

public class KafkaProducerWithAck {
    public static void main(String[] args) {
        // Configuration du producteur
        Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        
        // Configuration du niveau d'ACK
        props.put("acks", "all"); // Options: 0, 1, all
        
        // Création du producteur
        Producer<String, String> producer = new KafkaProducer<>(props);
        
        // Envoi asynchrone avec callback pour visualiser l'ACK
        String topic = "mon_topic";
        String key = "ma_cle";
        String value = "mon_message";
        
        producer.send(new ProducerRecord<>(topic, key, value), new Callback() {
            @Override
            public void onCompletion(RecordMetadata metadata, Exception exception) {
                if (exception == null) {
                    System.out.println("ACK reçu :");
                    System.out.println("  Topic: " + metadata.topic());
                    System.out.println("  Partition: " + metadata.partition());
                    System.out.println("  Offset: " + metadata.offset());
                    System.out.println("  Timestamp: " + metadata.timestamp());
                } else {
                    System.err.println("Erreur lors de l'envoi: " + exception.getMessage());
                }
            }
        });
        
        // Envoi synchrone (bloquant) pour voir l'ACK
        try {
            RecordMetadata metadata = producer.send(new ProducerRecord<>(topic, "cle2", "message2")).get();
            System.out.println("ACK reçu (synchrone) :");
            System.out.println("  Topic: " + metadata.topic());
            System.out.println("  Partition: " + metadata.partition());
            System.out.println("  Offset: " + metadata.offset());
            System.out.println("  Timestamp: " + metadata.timestamp());
        } catch (InterruptedException | ExecutionException e) {
            System.err.println("Erreur lors de l'envoi synchrone: " + e.getMessage());
        }
        
        // Fermeture du producteur
        producer.flush();
        producer.close();
    }
}
```

## Utilisation de l'API Python

Voici un exemple équivalent en Python avec `kafka-python` :

```python
from kafka import KafkaProducer
from kafka.errors import KafkaError

# Configuration du producteur
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    acks='all',  # Options: 0, 1, 'all'
    key_serializer=str.encode,
    value_serializer=str.encode
)

# Fonction de callback pour l'ACK
def on_send_success(record_metadata):
    print("ACK reçu :")
    print(f"  Topic: {record_metadata.topic}")
    print(f"  Partition: {record_metadata.partition}")
    print(f"  Offset: {record_metadata.offset}")
    print(f"  Timestamp: {record_metadata.timestamp}")

def on_send_error(excp):
    print(f"Erreur lors de l'envoi: {excp}")

# Envoi avec callback
topic = "mon_topic"
key = "ma_cle"
value = "mon_message"

# Envoi asynchrone avec callback
future = producer.send(topic, key=key, value=value)
future.add_callback(on_send_success).add_errback(on_send_error)

# Envoi synchrone pour voir l'ACK
try:
    record_metadata = producer.send(topic, key="cle2", value="message2").get(timeout=10)
    print("ACK reçu (synchrone) :")
    print(f"  Topic: {record_metadata.topic}")
    print(f"  Partition: {record_metadata.partition}")
    print(f"  Offset: {record_metadata.offset}")
    print(f"  Timestamp: {record_metadata.timestamp}")
except KafkaError as e:
    print(f"Erreur lors de l'envoi synchrone: {e}")

# Fermeture du producteur
producer.flush()
producer.close()
```

## Activation des logs de débogage

Pour une visibilité accrue des ACKs, vous pouvez activer les logs de débogage :

### En Java

```java
// Ajoutez cette configuration
props.put("logger.level", "DEBUG");
```

### En ligne de commande

Pour le producteur console, vous pouvez activer les logs de débogage :

```bash
# Linux
export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:config/tools-log4j.properties"
export KAFKA_OPTS="-Dlog4j.rootLogger=DEBUG"
bin/kafka-console-producer.sh --topic mon_topic --bootstrap-server localhost:9092 --property "acks=all"

# Windows
set KAFKA_LOG4J_OPTS=-Dlog4j.configuration=file:config/tools-log4j.properties
set KAFKA_OPTS=-Dlog4j.rootLogger=DEBUG
bin\windows\kafka-console-producer.bat --topic mon_topic --bootstrap-server localhost:9092 --property "acks=all"
```

## Utilisation d'outils de monitoring

Pour une surveillance en production, utilisez des outils comme :

1. **Kafka Manager / CMAK** : Visualisation des métriques de production et de consommation
2. **Prometheus + Grafana** : Surveillance des métriques Kafka, y compris les taux de succès/échec des ACKs
3. **Confluent Control Center** : Interface complète pour surveiller les ACKs et autres métriques

## Métriques JMX pour les ACKs

Kafka expose des métriques JMX qui peuvent être surveillées pour voir les ACKs :

- `kafka.producer:type=producer-metrics,client-id=(client-id)` 
  - `record-error-rate` : Taux d'erreurs (ACKs négatifs)
  - `record-send-rate` : Taux d'envoi
  - `request-latency-avg` : Latence moyenne des requêtes (incluant le temps d'attente des ACKs)

## Script pour tester les différents niveaux d'ACK

Voici un script Java simple pour tester et comparer les différents niveaux d'ACK :

```java
import org.apache.kafka.clients.producer.*;
import java.util.Properties;
import java.util.concurrent.CountDownLatch;

public class AckTester {
    public static void main(String[] args) throws InterruptedException {
        testAckLevel("0");
        testAckLevel("1");
        testAckLevel("all");
    }
    
    private static void testAckLevel(String ackLevel) throws InterruptedException {
        System.out.println("\nTest avec acks=" + ackLevel);
        
        Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("acks", ackLevel);
        
        Producer<String, String> producer = new KafkaProducer<>(props);
        
        final CountDownLatch latch = new CountDownLatch(10);
        long startTime = System.currentTimeMillis();
        
        for (int i = 0; i < 10; i++) {
            final int messageNum = i;
            producer.send(new ProducerRecord<>("test-ack", "key" + i, "value" + i), 
                (metadata, exception) -> {
                    long endTime = System.currentTimeMillis();
                    if (exception == null) {
                        System.out.printf("Message %d: ACK reçu en %d ms, partition=%d, offset=%d%n", 
                            messageNum, (endTime - startTime), metadata.partition(), metadata.offset());
                    } else {
                        System.err.println("Message " + messageNum + ": Erreur: " + exception.getMessage());
                    }
                    latch.countDown();
                });
        }
        
        latch.await();
        producer.close();
    }
}
```

## Conclusion

Pour visualiser les ACKs au niveau du producteur Kafka :

1. **Producteur console** : Pas de visualisation directe, utilisez les logs de débogage
2. **API Java/Python** : Utilisez des callbacks pour intercepter les métadonnées de l'ACK
3. **Outils de monitoring** : Pour une surveillance en production
4. **Métriques JMX** : Pour une intégration avec des systèmes de surveillance existants

Le choix du niveau d'ACK (0, 1, all) affecte directement la fiabilité et la performance de votre système Kafka.
