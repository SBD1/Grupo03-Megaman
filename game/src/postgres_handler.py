import psycopg2 as pg
from dotenv import load_dotenv
import os

load_dotenv()
db_name = os.environ["DBNAME"]
db_user = os.environ["DBUSER"]
db_pass = os.environ["DBPASS"]
db_host = os.environ["DBHOST"]
db_port = os.environ["DBPORT"]

connection = pg.connect(dbname=db_name, user=db_user, password=db_pass, host=db_host, port=db_port)
main_cursor = connection.cursor()

def get_cursor():
    return main_cursor
    
def close_all():
    main_cursor.close()
    connection.close()

def commit():
    connection.commit()
