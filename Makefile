#### Main

provision: twitter-forwarder.build streams.build tweets-transformation.build tf.apply connectors.add.both twitter-forwarder.start

tf.apply:
	terraform apply --auto-approve terraform

tf.destroy:
	terraform destroy

#### Kube Dashboard

dashboard.install:
	helm install stable/kubernetes-dashboard --name kube-dashboard

dashboard.delete:
	helm delete kube-dashboard

dashboard.token:
	kubectl get serviceaccounts kube-dashboard-kubernetes-dashboard -o json | jq '.secrets[0].name' -r | xargs kubectl get secret -o json | jq '.data.token | @base64d' -r | pbcopy

dashboard.open: dashboard.token
	open http://localhost:8001/api/v1/namespaces/default/services/https:kube-dashboard-kubernetes-dashboard:https/proxy/#!/overview?namespace=default

#### Confluent Control Center

control-center.open:
	open http://localhost:9021 && \
	kubectl port-forward svc/confluent-cp-control-center 9021:9021 -n kafka

#### Jenkins

jenkins.password:
	kubectl get secret --namespace kafka jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode | pbcopy

jenkins.open: jenkins.password
	open http://localhost:8081

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
	terraform apply -auto-approve terraform

twitter-forwarder.start:
	curl -s http://localhost:3000/twitter/on

twitter-forwarder.stop:
	curl -s http://localhost:3000/twitter/off

twitter-forwarder.logs:
	kubectl logs twitter-forwarder -f -n kafka


#### Tweets Transformer

tweets-transformation.build:
	docker build tweets-transformation -t sfo/tweets-transformation

tweets-transformation.update: tweets-transformation.build
	terraform taint kubernetes_pod.tweets-transformation && \
	terraform apply -auto-approve terraform

tweets-transformation.logs:
	kubectl logs tweets-transformation -f -n kafka


#### Streams App

streams.build:
	docker build kafka-streams -t sfo/kafka-streams

streams.update: streams.build
	terraform taint kubernetes_pod.kafka-streams && \
	terraform apply -auto-approve terraform

streams.logs:
	kubectl logs kafka-streams -f -n kafka

#### PostgreSQL

pg.psql:
	kubectl exec -it pg-postgresql-0 -n kafka -- sh -c 'PGPASSWORD=pg psql -U postgres sfdata'

pg.tweets.select:
	kubectl exec -it pg-postgresql-0 -n kafka -- sh -c 'PGPASSWORD=pg psql -U postgres sfdata -c "select * from tweets limit 2;"'

pg.tweets.count:
	kubectl exec -it pg-postgresql-0 -n kafka -- sh -c 'PGPASSWORD=pg psql -U postgres sfdata -c "select count(*) from tweets;"'

pg.counts:
	kubectl exec -it pg-postgresql-0 -n kafka -- sh -c 'PGPASSWORD=pg psql -U postgres sfdata -c "select * from counts order by count desc;"'

#### Grafana

grafana.password:
	kubectl get secret --namespace kafka grafana -o json | jq '.data["admin-password"] | @base64d' -r | pbcopy

grafana.open: grafana.password
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

consumer.tweets:
	POD=`kubectl get pod -n kafka -l app=cp-schema-registry -o json | jq '.items[0].metadata.name' -r` && \
	kubectl exec -c cp-schema-registry-server -it $$POD -n kafka -- /bin/bash -c "unset JMX_PORT && /usr/bin/kafka-avro-console-consumer \
		--bootstrap-server confluent-cp-kafka:9092 \
		--topic pgtweets \
		--property print.key=true \
		--property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \
    --property schema.registry.url=http://confluent-cp-schema-registry:8081"

consumer.word_count:
	kubectl exec -c cp-kafka-broker -it confluent-cp-kafka-0 -n kafka -- /bin/bash /usr/bin/kafka-console-consumer \
		--bootstrap-server localhost:9092 \
		--property print.key=true \
		--topic word_count

consumer.count_by_country:
	POD=`kubectl get pod -n kafka -l app=cp-schema-registry -o json | jq '.items[0].metadata.name' -r` && \
	kubectl exec -c cp-schema-registry-server -it $$POD -n kafka -- /bin/bash -c "unset JMX_PORT && /usr/bin/kafka-avro-console-consumer \
		--bootstrap-server confluent-cp-kafka:9092 \
		--topic counts \
		--property print.key=true \
		--property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \
    --property schema.registry.url=http://confluent-cp-schema-registry:8081"