from flask import Flask, escape, request
from kafka import KafkaProducer
from kafka.errors import KafkaError

producer = KafkaProducer(bootstrap_servers=['confluent-cp-kafka:9092'])

app = Flask(__name__)

@app.route('/')
def ping():
  return 'Pong'

@app.route('/send')
def hello():
    name = request.args.get("name", "World")
    # Asynchronous by default
    meta = producer.send('my-topic', name.encode('utf-8')).get(timeout=10)
    return f'Message sent: {meta}!'

app.run(host='0.0.0.0', port=80)