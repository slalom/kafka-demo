# Kafka Platform demonstration

![Diagram](diagram.png)

## Prerequisites

- Docker with Kubernetes (standard on Mac and Windows)
- helm [link](https://helm.sh/)
- terraform [link](https://www.terraform.io/)
- jq (for parsing kubectl responses) [link](https://stedolan.github.io/jq/)
- git (for getting Confluent helm charts)

## Installation

### Prep

1. Get your local Kubernetes up and running
2. Test it with `kubectl cluster-info`
3. `terraform -chdir=terraform init`
4. `make kube.proxy` and keep it running on the side
5. Sign up for a Twitter dev account [here](https://developer.twitter.com/) and insert the Twitter token in `twitter-forwarder/.env`

### Provisioning

1. `make provision`

### Destroying

1. `make tf.destroy`

### Kube dashboard

1. Install the dashboard (it's purposefully not part of the solution):

`helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/`

`helm install kube-dashboard kubernetes-dashboard/kubernetes-dashboard`

2. `make dashboard.open`. This will open the web app and put the token in your clipboard
3. Use the token from your clipboard

## Accessing services

### Control Center UI

1. `make control-center.open`

### Grafana

1. `make grafana.open`. User: admin, password is in your clipboard.

### Twitter forwarder

The Twitter forwarder is started by default, but you can also stop it.

1. `make twitter-forwarder.start` to start feeding Twitter messages to the database
2. `make twitter-forwarder.stop` to... stop

### Jenkins

1. Wait a few minutes for the service to come up
2. `make jenkins.open`
3. `make jenkins.password`
4. Log in with user admin and password from the output above

### Console consumer for Twitter feed

1. `make consumer.twitter`
