import psycopg2

hostname = 'pg-postgresql'
username = 'postgres'
password = 'pg'
database = 'sfdata'

conn = psycopg2.connect( host=hostname, user=username, password=password, dbname=database )
conn.set_session(autocommit=True)
cur = conn.cursor()

def insert(message):
  text = message["data"]["text"]
  language = message["data"]["lang"] or "Unknown"
  source = message["data"]["source"] or "Unknown"
  # print(f"{message['data']['text']}, {message['data']['lang']} ")
  cur.execute( "INSERT INTO tweets (text, language, source) VALUES (%s, %s, %s)", (text, language, source) )