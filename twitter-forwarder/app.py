import requests
import os
from dotenv import load_dotenv
import json
from db import DB, MockDB

from flask import Flask

load_dotenv()
app = Flask(__name__)
bearer_token = os.getenv('TWITTER_KEY')
db = DB()

def create_url():
    return "https://api.twitter.com/2/tweets/sample/stream?&tweet.fields=lang,source"

def bearer_oauth(r):
    r.headers["Authorization"] = f"Bearer {bearer_token}"
    r.headers["User-Agent"] = "v2SampledStreamPython"
    return r

url = create_url()
response = requests.request("GET", url, auth=bearer_oauth, stream=True)
for response_line in response.iter_lines():
        if response_line:
            message = json.loads(response_line)
            db.insert(message)

@app.route("/")
def ping():
    return "Pong"


app.run(host="0.0.0.0", port=80)

