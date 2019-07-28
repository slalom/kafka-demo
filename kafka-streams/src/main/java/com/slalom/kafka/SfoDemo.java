package com.slalom.kafka;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.KTable;
import org.apache.kafka.streams.kstream.Produced;

import java.util.Arrays;
import java.util.Properties;

public class SfoDemo {

    public static void main(String[] args) {

        Properties config = new Properties();
        config.put(StreamsConfig.APPLICATION_ID_CONFIG, "sfo-demo-app-id");
        config.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        config.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        config.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        config.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        StreamsBuilder builder = new StreamsBuilder();
        // 1 - Stream from Kafka
        KStream<String, String> wordCountInput = builder.stream("word-count-input");
        // 2 - map values to lower case

        KTable<String, Long> wordCounts = wordCountInput.mapValues(value -> value.toLowerCase())

                // 3 - flatten values split by space

                .flatMapValues(value -> Arrays.asList(value.split(" ")))

                // 4 - select a key to apply a key

                .selectKey((key, value) -> value)

                // 5 - group by key before aggregate

                .groupByKey()

                // 6 - count occurances

                .count();


        wordCounts.toStream().to("word-count-topic", Produced.with(Serdes.String(), Serdes.Long()));

        KafkaStreams streams = new KafkaStreams(builder.build(), config);

        streams.start();

        System.out.println(streams.toString());

        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));

    }
}
