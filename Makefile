#### Kube Dashboard

dashboard.install:
	helm install --name kube-dashboard stable/kubernetes-dashboard

dashboard.delete:
	helm del --purge kube-dashboard

proxy.start:
	kubectl proxy

dashboard.token:
	kubectl get serviceaccounts kube-dashboard-kubernetes-dashboard -o json | jq '.secrets[0].name' -r | xargs kubectl get secret -o json | jq '.data.token | @base64d' -r

dashboard.open:
	open http://localhost:8001/api/v1/namespaces/default/services/https:kube-dashboard-kubernetes-dashboard:https/proxy/#!/overview?namespace=default

#### Confluent

confluent.install:
	git clone https://github.com/confluentinc/cp-helm-charts.git
	helm install --name confluent --namespace kafka cp-helm-charts/

confluent.proxy:
	kubectl port-forward svc/confluent-cp-control-center 8080:9021 -n kafka

confluent.delete:
	helm del --purge confluent
	rm -rf cp-helm-charts

confluent.open:
	open http://localhost:8080

#### Python App

install-python-app: build-python-app
	helm install --name python-app ./python-app-chart --namespace kafka

build-python-app:
	docker build python-app -t sfo/python-app

delete-python-app:
	helm del --purge python-app

run-consumer:
	kubectl exec -c cp-kafka-broker -it confluent-cp-kafka-0 -n kafka -- /bin/bash /usr/bin/kafka-console-consumer --bootstrap-server localhost:9092 --topic my-topic --from-beginning	
