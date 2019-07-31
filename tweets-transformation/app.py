import threading
from confluent_kafka.avro import AvroConsumer
from confluent_kafka import avro
from confluent_kafka import KafkaException
from flask import Flask
from confluent_kafka import Producer
import json

app = Flask(__name__)

@app.route("/")
def ping():
    return "Pong"

c = AvroConsumer({'bootstrap.servers': 'confluent-cp-kafka:9092',
              'group.id': 'word-count-group',
              'session.timeout.ms': 6000,
              'schema.registry.url': 'http://confluent-cp-schema-registry:8081',
              'auto.offset.reset': 'earliest'})

c.subscribe(['pgtweets'])

def wrap_in_schema(msg):
    return {
        'schema': {
            'type': 'struct',
            'fields': [
                {
                    'type': 'int64',
                    'optional': 'false',
                    'field': 'words' 
                },
                {
                    'type': 'string',
                    'optional': 'false',
                    'field': 'created_at' 
                }
            ]
        },
        'payload': msg
    }

def transform_message(input):
    tweet_length = len(input.value()['text'].split())
    message = {'words': tweet_length, 'created_at': input.value()['datetime']}
    return json.dumps(wrap_in_schema(message))

p = Producer({'bootstrap.servers': 'confluent-cp-kafka:9092'})

class mythread(threading.Thread):
  
  def __init__(self, c):
    threading.Thread.__init__(self)
    self.c = c

  def run(self):
    try:
        while True:
            msg = self.c.poll(timeout=1.0)
            if msg is None:
                continue
            if msg.error():
                raise KafkaException(msg.error())
            else:
                output = transform_message(msg.value())
                key = msg.value()['country']
                p.produce('word_count', output, key)

    except KeyboardInterrupt:
        print('Aborted by user\n')

    finally:
        self.c.close()

poll = mythread(c)
poll.start()

app.run(host="0.0.0.0", port=80)