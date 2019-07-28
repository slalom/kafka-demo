import psycopg2

hostname = 'pg-postgresql'
username = 'postgres'
password = 'pg'
database = 'sfdata'

conn = psycopg2.connect( host=hostname, user=username, password=password, dbname=database )
conn.set_session(autocommit=True)
cur = conn.cursor()

def insert(message):
  text = message.message["text"]
  country = message.message["place"] and message.message["place"]["country"] or "Unknown"
  cur.execute( "INSERT INTO tweets (text, country) VALUES (%s, %s)", (text, country) )