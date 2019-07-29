provision: tf.apply twitter-forwarder.build streams.build connectors.add.both twitter-forwarder.start

tf.apply:
	terraform apply --auto-approve
#### Kube Dashboard

dashboard.token:
	kubectl get serviceaccounts kube-dashboard-kubernetes-dashboard -o json | jq '.secrets[0].name' -r | xargs kubectl get secret -o json | jq '.data.token | @base64d' -r

dashboard.open:
	open http://localhost:8001/api/v1/namespaces/default/services/https:kube-dashboard-kubernetes-dashboard:https/proxy/#!/overview?namespace=default

#### Jenkins

jenkins.password:
	kubectl get secret --namespace kafka jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode

jenkins.open:
	open http://localhost:8081

#### Confluent Control Center

control-center.proxy:
	kubectl port-forward svc/confluent-cp-control-center 9021:9021 -n kafka

control-center.open:
	open http://localhost:9021

#### Confluent Kafka Connect

connectors.wait.for.confluent:
	bash -c 'while [[ `curl http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors/ -s -o /dev/null -w ''%{http_code}''` != "200" ]]; do sleep 5; done'

connector.list:
	curl -s http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors/ | jq

connector.source.add:
	curl -d @pg/pg-source.json -H "Content-Type: application/json" -X POST http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors

connector.source.status:
	curl http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors/pg-source/status | jq

connector.source.delete:
	curl -X DELETE http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors/pg-source

connector.sink.add:
	curl -d @pg/pg-sink.json -H "Content-Type: application/json" -X POST http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors

connector.sink.status:
	curl http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors/pg-sink/status | jq

connector.sink.delete:
	curl -X DELETE http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors/pg-sink

connectors.add.both: connectors.wait.for.confluent connector.source.add connector.sink.add

#### Twitter Forwarder

twitter-forwarder.build:
	docker build twitter-forwarder -t sfo/twitter-forwarder

twitter-forwarder.update: twitter-forwarder.build
	terraform taint kubernetes_pod.twitter-forwarder && \
	terraform apply -auto-approve

twitter-forwarder.start:
	curl -s http://localhost:3000/twitter/on

twitter-forwarder.stop:
	curl -s http://localhost:3000/twitter/off

twitter-forwarder.logs:
	kubectl logs twitter-forwarder -f -n kafka

#### Streams App

streams.build:
	docker build kafka-streams -t sfo/kafka-streams

streams.update: streams.build
	terraform taint kubernetes_pod.kafka-streams && \
	terraform apply -auto-approve

streams.logs:
	kubectl logs kafka-streams -f -n kafka

#### PostgreSQL

pg.psql:
	kubectl exec -it pg-postgresql-0 psql -n kafka -- -U postgres sfdata

pg.proxy:
	kubectl port-forward svc/pg-postgresql-headless -n kafka 5432:5432


#### Grafana

grafana.password:
	kubectl get secret --namespace kafka grafana -o json | jq '.data["admin-password"] | @base64d' -r

grafana.open:
	open http://localhost:8083

#### Other

kube.proxy:
	kubectl proxy

kube.list.svc:
	kubectl get svc -n kafka

kube.list.pods:
	kubectl get pods -n kafka

confluent.logs:
	kubectl logs confluent-cp-kafka-0 -c cp-kafka-broker -n kafka -f

consumer.twitter:
	kubectl exec -c cp-kafka-broker -it confluent-cp-kafka-0 -n kafka -- /bin/bash /usr/bin/kafka-console-consumer \
		--bootstrap-server localhost:9092 \
		--topic pgtweets

consumer.counts:
	kubectl exec -c cp-kafka-broker -it confluent-cp-kafka-0 -n kafka -- /bin/bash /usr/bin/kafka-console-consumer \
		--bootstrap-server localhost:9092 \
		--topic tweet-countries-topic \
		--formatter kafka.tools.DefaultMessageFormatter \
    --property print.key=true \
    --property print.value=true \
    --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \
    --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer