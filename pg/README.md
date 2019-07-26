
# Deploying pg helm chart with values over ridden
helm install --name pg -f pg-values.yaml stable/postgresql

Note: Please wait for the pg server to come up. It take some time to load up. Once done, do the port mapping

# port mapping for pg
kubectl port-forward --namespace default svc/pg-postgresql 5432:5432

# Checking the pg connection
psql --host 127.0.0.1 -U postgres -p 5432


# Create a table 





# Deploying a kafka-connector for pg

This is assumed: kubectl port-forward service/kafka-cp-kafka-connect 8083:8083

## run this to deploy a connector
curl -d @pg-jdbc-connector.json -H "Content-Type: application/json" -X POST http://localhost:8083/connectors

## To check the status of the running connector
curl -X GET http://localhost:8083/connectors/pg-connector/status | jq

## To delete the connector
curl -X DELETE http://localhost:8083/connectors/pg-connector