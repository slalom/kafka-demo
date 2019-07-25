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


#### Jenkins

jenkins.install:
	helm install --name jenkins --namespace kafka stable/jenkins --set master.servicePort=8081

jenkins.password:
	kubectl get secret --namespace kafka jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode

jenkins.open:
	open http://localhost:8081

jenkins.delete:
	helm del --purge jenkins	


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

client.install: client.build
	helm install --name python-app ./python-app-chart --namespace kafka

client.build:
	docker build python-app -t sfo/python-app

client.delete:
	helm del --purge python-app

client.open:
	open http://localhost:8001/api/v1/namespaces/kafka/services/http:python-app-python-app-chart:http/proxy

#### Other

consumer.run:
	kubectl exec -c cp-kafka-broker -it confluent-cp-kafka-0 -n kafka -- /bin/bash /usr/bin/kafka-console-consumer --bootstrap-server localhost:9092 --topic my-topic --from-beginning	
