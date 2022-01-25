FROM confluentinc/cp-kafka-connect:6.1.0

RUN echo "===> Installing JDBC connector"
RUN confluent-hub install --no-prompt --verbose --component-dir /usr/share/java confluentinc/kafka-connect-jdbc:10.3.1