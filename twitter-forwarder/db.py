import psycopg2

hostname = 'pg-postgresql'
username = 'postgres'
password = 'pg'
database = 'sfdata'

class DB:

  def __init__(self):
    conn = psycopg2.connect( host=hostname, user=username, password=password, dbname=database )
    conn.set_session(autocommit=True)
    self.cur = conn.cursor()

  def insert(self, message):
    text = message["text"]
    language = message["lang"] or "Unknown"
    source = message["source"] or "Unknown"
    self.cur.execute( "INSERT INTO tweets (text, language, source) VALUES (%s, %s, %s)", (text, language, source) )


class MockDB:

  def insert(self, message):
    text = message["text"]
    language = message["lang"] or "Unknown"
    source = message["source"] or "Unknown"
    print(f"{language}, {source} ")