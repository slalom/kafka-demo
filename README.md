# RFP Demo

## Prerequisites

- Docker with Kubernetes
- helm
- terraform
- jq (for parsing kubectl responses)
- git (for getting Confluent helm charts)

## Installation

### Prep

1. Get your local Kube up and running
2. `terraform init terraform`
3. `make kube.proxy`

### Kube dashboard

1. `make dashboard.open`. This will open the web app and put the token in your clipboard
2. Use the token from your clipboard

### Provisioning

1. `make kube.proxy`
2. `make provision`
3. `make control-center.proxy`
4. `make control-center.open`

### Twitter forwarder

1. `make kube.proxy`
2. `make connector.add`
3. `make twitter-forwarder.start` to start feeding Twitter messages to the database
4. `make twitter-forwarder.stop` to... stop

## Accessing services

### Jenkins

1. Wait a few minutes for the service to come up
2. `make jenkins.open`
3. `make jenkins.password`
4. Log in with user admin and password from the output above


### Confluent platform

1. Wait a few minutes for the service to come up
2. `make control-center.proxy`
3. Open new terminal tab
4. `make control-center.open`

### Grafana

1. `make grafana.open`
2. User: admin, password `make grafana.password`
3. Import dashboard `grafana/kafka-dashboard`

### Console consumer for Twitter feed

1. `make consumer.twitter`