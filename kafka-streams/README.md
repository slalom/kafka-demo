
## Assumptions

These 2 topics exist - word-count-input & word-count-topic

## How to build the streams app?

In sfo-demo/kafka-streams folder run

> mvn clean
> mvn package

The complete jar would be created under target folder as 

> sfo-demo-1.0-SNAPSHOT-jar-with-dependencies.jar

## How to run the streams app?

> java -jar sfo-demo-1.0-SNAPSHOT-jar-with-dependencies.jar

The above one assumes kafka is under localhost:9092. In a multi cluster environment - the advertised listeners must resolve.

## How to test it?

Run a kafka producer to topic `word-count-input` and start typing in the words

`kafka-console-producer --broker-list localhost:9092 --topic word-count-input`

Run a kafka consumer on `word-count-topic` to see the messages being word counted

`bin/kafka-console-consumer --bootstrap-server localhost:9092 \`
` --topic word-count-topic \ `
` --from-beginning \`
` --formatter kafka.tools.DefaultMessageFormatter \`
` --property print.key=true \`
` --property print.value=true \`
` --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \`
` --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer`


 # How to edit the code?

 Open up the project and under src/main/java - there is a SfoDemo class. This class is Java code and can be modified to read from Twitter or any other data source.


