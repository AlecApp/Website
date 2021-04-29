from decimal import Decimal
from psycopg2 import sql
import json
import psycopg2

def query_movies(year):

 #   db_user = os.environ.get('DB_USER')
 #   db_password = os.environ.get('DB_PASSWORD')
 #   db_host = os.environ.get('DB_HOST')
 #   db_port = os.environ.get('DB_PORT')
 #   db_name = os.environ.get('DB_NAME')
    db_user = os.environ.get('master')
    db_password = os.environ.get('esfmVSWBp3qV7j6Vjzn1KQKeDKuhqu46')
    db_host = os.environ.get('aurora-db-postgres-demo.cluster-chfxmjufjx0y.us-east-1.rds.amazonaws.com')
    db_port = os.environ.get('5432')
    db_name = os.environ.get('demo')

    try:
        connection = psycopg2.connect(
            user = db_user,
            password = db_password,
            host = db_host,
            port = db_port,
            database = db_name
        )
        cursor = connection.cursor()
        cursor.execute("""SELECT * FROM movies WHERE year={0}""".format(year))
        results = cursor.fetchall()
        with open('/tmp/results.txt', 'w') as f:
            f.write(results)
 #       cursor.execute(
 #       """CREATE TABLE movies (
 #           title VARCHAR(255) NOT NULL,
 #           year INTEGER NOT NULL,
 #           plot VARCHAR(255) NOT NULL,
 #           PRIMARY KEY (title, year)
 #           )"""
 #       )
#
 #       for movie in movie_list:
 #           if not "plot" in movie["info"]:
 #               plot = "None"
 #           else:
 #               plot = movie["info"]["plot"]
 #               plot = plot[0:255]
 #           pg_insert = """INSERT INTO movies (title, year, plot) VALUES (%s,%s,%s)"""
 #           inserted_values = (movie["title"], int(movie["year"]), plot)
 #           cursor.execute(pg_insert, inserted_values)

        connection.commit()
        count = cursor.rowcount
        print (count, "Successfully inserted")


    except(Exception, psycopg2.Error) as error:
        print("Error connecting to PostgreSQL database", error)
        connection = None

    finally:
        if(connection != None):
            cursor.close()
            connection.close()
            print("PostgreSQL connection is now closed")
            