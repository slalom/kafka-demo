#### Main

provision: twitter-forwarder.build streams.build tweets-transformation.build docker.build tf.apply connectors.add.both

reprovision: tf.destroy provision

docker.build:
	docker build kafka-connect-jdbc -t slalom/kafka-connect-jdbc

tf.apply:
	terraform -chdir=terraform apply --auto-approve

tf.destroy:
	terraform -chdir=terraform destroy --auto-approve

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
	bash -c 'sec=0; while [[ `curl http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors/ -s -o /dev/null -w ''%{http_code}''` != "200" ]]; do echo "Waiting for Kafka... ($${sec}s)" && sleep 5 && ((sec=sec+5)); done'

connector.install.jdbc:
	POD=`kubectl get pod -n kafka -l app=cp-kafka-connect -o json | jq '.items[0].metadata.name' -r` && \
	kubectl exec -c cp-kafka-connect-server -it $$POD -n kafka -- confluent-hub install --no-prompt --verbose --component-dir /usr/share/java confluentinc/kafka-connect-jdbc:10.3.1

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
	docker build twitter-forwarder -t slalom/twitter-forwarder

twitter-forwarder.update: twitter-forwarder.build
	terraform -chdir=terraform taint kubernetes_pod.twitter-forwarder && \
	terraform -chdir=terraform apply -auto-approve

twitter-forwarder.logs:
	kubectl logs twitter-forwarder -f -n kafka


#### Tweets Transformer

tweets-transformation.build:
	docker build tweets-transformation -t slalom/tweets-transformation

tweets-transformation.update: tweets-transformation.build
	terraform -chdir=terraform taint kubernetes_pod.tweets-transformation && \
	terraform -chdir=terraform apply -auto-approve

tweets-transformation.logs:
	kubectl logs tweets-transformation -f -n kafka


#### Streams App

streams.build:
	docker build kafka-streams -t slalom/kafka-streams

streams.update: streams.build
	terraform -chdir=terraform taint kubernetes_pod.kafka-streams && \
	terraform -chdir=terraform apply -auto-approve

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

consumer.count_by_language:
	POD=`kubectl get pod -n kafka -l app=cp-schema-registry -o json | jq '.items[0].metadata.name' -r` && \
	kubectl exec -c cp-schema-registry-server -it $$POD -n kafka -- /bin/bash -c "unset JMX_PORT && /usr/bin/kafka-avro-console-consumer \
		--bootstrap-server confluent-cp-kafka:9092 \
		--topic counts \
		--property print.key=true \
		--property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \
    --property schema.registry.url=http://confluent-cp-schema-registry:8081"