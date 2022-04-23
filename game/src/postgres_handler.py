import psycopg2 as pg

# TODO parametrizar a conexão
connection = pg.connect('dbname=megaman user=frostwagner')
main_cursor = connection.cursor()

def get_cursor():
    return main_cursor
    
def close_all():
    main_cursor.close()
    connection.close()

def commit():
    connection.commit()
