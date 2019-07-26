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
2. `terraform init`

### Provisioning

1. `terraform apply`

## Accessing services

### Kube dashboard

1. `make kube.proxy`
2. Open new terminal tab
3. `make dashboard.token`
4. `make dashboard.open`
5. Use the token from previous step for authentication


### Jenkins

1. Wait a few minutes for the service to come up
2. `make jenkins.open`
3. `make jenkins.password`
4. Log in with user admin and password from the output above


### Confluent platform

1. Wait a few minutes for the service to come up
2. `make confluent.proxy`
3. Open new terminal tab
4. `make confluent.open`

### Python Twitter Publisher

1. `make kube.proxy` if you don't have it running yet
2. `make publisher.start` to start feeding Twitter messages to the topic
3. `make publisher.stop` to... stop


### Console consumer for Twitter feed

1. `make consumer.twitter`