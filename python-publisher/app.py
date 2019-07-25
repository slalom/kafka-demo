from flask import Flask, escape, request
from kafka import KafkaProducer
from kafka.errors import KafkaError

from pubnub.callbacks import SubscribeCallback
from pubnub.pnconfiguration import PNConfiguration
from pubnub.pubnub import PubNub

producer = KafkaProducer(bootstrap_servers=["confluent-cp-kafka:9092"])

pnconfig = PNConfiguration()
pnconfig.subscribe_key = "sub-c-78806dd4-42a6-11e4-aed8-02ee2ddab7fe"
pubnub = PubNub(pnconfig)


class MySubscribeCallback(SubscribeCallback):
    def message(self, pubnub, message):
        producer.send("twitter", str(message.message).encode("utf-8"))


pubnub.add_listener(MySubscribeCallback())

app = Flask(__name__)


@app.route("/")
def ping():
    return "Pong"


@app.route("/twitter/on")
def twitter_on():
    pubnub.subscribe().channels("pubnub-twitter").execute()
    return {"status": "ON"}


@app.route("/twitter/off")
def twitter_off():
    pubnub.unsubscribe().channels("pubnub-twitter").execute()
    return {"status": "OFF"}


app.run(host="0.0.0.0", port=80)

