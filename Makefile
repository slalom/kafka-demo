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

kafka-connect.pg-connector.add:
	curl -d @pg/pg-jdbc-connector.json -H "Content-Type: application/json" -X POST http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors

kafka-connect.pg-connector.status:
	curl http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors/pg-connector/status | jq

kafka-connect.pg-connector.delete:
	curl -X DELETE http://localhost:8001/api/v1/namespaces/kafka/services/http:confluent-cp-kafka-connect:kafka-connect/proxy/connectors/pg-connector

#### Python Publisher

publisher.build:
	docker build python-publisher -t sfo/python-publisher

publisher.update: publisher.build
	terraform taint helm_release.publisher && \
	terraform apply -auto-approve

publisher.start:
	curl -s http://localhost:8001/api/v1/namespaces/kafka/services/http:publisher-python-app:http/proxy/twitter/on

publisher.stop:
	curl -s http://localhost:8001/api/v1/namespaces/kafka/services/http:publisher-python-app:http/proxy/twitter/off

publisher.logs:
	kubectl get pods --selector=app.kubernetes.io/instance=publisher -n kafka -o json | jq '.items[0].metadata.name' -r | xargs kubectl logs -f -n kafka

#### Other

kube.proxy:
	kubectl proxy

consumer.twitter:
	kubectl exec -c cp-kafka-broker -it confluent-cp-kafka-0 -n kafka -- /bin/bash /usr/bin/kafka-console-consumer --bootstrap-server localhost:9092 --topic twitter

psql:
	kubectl exec -it pg-postgresql-0 psql -n kafka -- -U postgres sfdata
