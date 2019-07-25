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
    message = request.args.get('message', 'Hello World')
    topic = request.args.get('topic', 'a-topic')
    print(f'topic is {topic}')
    # Asynchronous by default
    meta = producer.send(topic, message.encode('utf-8')).get(timeout=10)
    return {'timestamp': meta.timestamp, 'offset': meta.offset, 'partition':meta.partition}

app.run(host='0.0.0.0', port=80)