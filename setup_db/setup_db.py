from decimal import Decimal
from psycopg2 import sql
import json
import psycopg2

def load_data(movie_list):
    try:
        connection = psycopg2.connect(
            user = "MASTER_USER",
            password = "MASTER_PASSWORD",
            host = "DB_HOST",
            port = "DB_PORT",
            database = "DB_NAME"
        )

        cursor = connection.cursor()
        cursor.execute(
        """CREATE TABLE movies (
            title VARCHAR(255) NOT NULL,
            year INTEGER NOT NULL,
            plot VARCHAR(255) NOT NULL,
            PRIMARY KEY (title, year)
            )"""
        )

        for movie in movie_list:
            if not "plot" in movie["info"]:
                plot = "None"
            else:
                plot = movie["info"]["plot"]
                plot = plot[0:255]
            pg_insert = """INSERT INTO movies (title, year, plot) VALUES (%s,%s,%s)"""
            inserted_values = (movie["title"], int(movie["year"]), plot)
            cursor.execute(pg_insert, inserted_values)

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
            

def lambda_handler(event, context):
    with open("moviedata.json") as json_file:
        movie_list = json.load(json_file, parse_float=Decimal)
    load_data(movie_list)