import csv
import time
from db import DB, MockDB

from flask import Flask

mock = False

def get_db():
    return MockDB() if mock else DB()

app = Flask(__name__)
db = get_db()

def parse_line(line):
    return {
        'text': line[3],
        'lang': line[11],
        'source': line[5]
    }

with open('tweets.csv') as f:
    csv_reader = csv.reader(f)
    # skip the header
    next(csv_reader)
    for tokens in csv_reader:
        db.insert(parse_line(tokens))
        time.sleep(0.1)

@app.route("/")
def ping():
    return "Pong"


app.run(host="0.0.0.0", port=80)

