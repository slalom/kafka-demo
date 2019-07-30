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
              'group.id': 'group-0',
              'session.timeout.ms': 6000,
              'schema.registry.url': 'http://confluent-cp-schema-registry:8081',
              'auto.offset.reset': 'earliest'})

c.subscribe(['pgtweets'])

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
                tweet_length = len(msg.value()['text'].split())
                message = {'words':tweet_length}
                p.produce('word_count', json.dumps(message), msg.value()['country'])

    except KeyboardInterrupt:
        print('Aborted by user\n')

    finally:
        self.c.close()

poll = mythread(c)
poll.start()

app.run(host="0.0.0.0", port=80)