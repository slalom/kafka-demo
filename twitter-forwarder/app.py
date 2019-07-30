from flask import Flask

import db
import twitter_feed

app = Flask(__name__)

twitter_feed.create(lambda message: db.insert(message))

@app.route("/")
def ping():
    return "Pong"


@app.route("/twitter/on")
def twitter_on():
    twitter_feed.on()
    return {"status": "ON"}


@app.route("/twitter/off")
def twitter_off():
    twitter_feed.off()
    return {"status": "OFF"}


app.run(host="0.0.0.0", port=80)

