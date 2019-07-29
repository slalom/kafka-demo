package com.slalom.kafka;

import io.confluent.kafka.streams.serdes.avro.GenericAvroSerde;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.Consumed;
import org.apache.kafka.streams.kstream.Produced;

import java.util.Map;
import java.util.Properties;
import java.util.regex.Pattern;

public class SfoDemo {

    public static void main(String[] args) {

        Properties config = new Properties();
        config.put(StreamsConfig.APPLICATION_ID_CONFIG, "sfo-demo-app-id");
        config.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "confluent-cp-kafka:9092");
        config.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        config.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        config.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        config.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 10 * 1000);
        config.put(StreamsConfig.CACHE_MAX_BYTES_BUFFERING_CONFIG, 0);


        var avroSerde = new GenericAvroSerde();
        avroSerde.configure(Map.of("schema.registry.url", "http://confluent-cp-schema-registry:8081"), false);

        StreamsBuilder builder = new StreamsBuilder();

        builder.stream("pgtweets", Consumed.with(Serdes.String(), avroSerde))
                .mapValues(value -> value.get("country").toString())
                .groupBy((keyIgnored, word) -> word)
                .count()
                .filter((word, count) -> count > 0)
                .toStream().to("tweet-countries-topic", Produced.with(Serdes.String(), Serdes.Long()));


        KafkaStreams streams = new KafkaStreams(builder.build(), config);

        streams.start();

        System.out.println(streams.toString());

        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));

    }
}
