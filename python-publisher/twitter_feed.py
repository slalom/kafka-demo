from pubnub.callbacks import SubscribeCallback
from pubnub.pnconfiguration import PNConfiguration
from pubnub.pubnub import PubNub

pnconfig = PNConfiguration()
pnconfig.subscribe_key = "sub-c-78806dd4-42a6-11e4-aed8-02ee2ddab7fe"
pubnub = PubNub(pnconfig)

class MySubscribeCallback(SubscribeCallback):

    def __init__(self, action):
      self.action = action

    def message(self, pubnub, message):
        self.action(message)

def create(action):
  pubnub.add_listener(MySubscribeCallback(action))

def on():
  pubnub.subscribe().channels("pubnub-twitter").execute()

def off():
  pubnub.unsubscribe().channels("pubnub-twitter").execute()
