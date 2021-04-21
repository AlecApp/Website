from decimal import Decimal
import json
import psycopg2

def load_data(movies):
    try:
        connection = psycopg2.connect(
            user = "MASTER_USER",
            password = "MASTER_PASSWORD",
            port = "5432",
            database = "DATABASE_NAME"
        )

        cursor = connection.cursor()
        cursor.execute("CREATE TABLE movies")
        for movie in movies:
            pg_insert = """INSERT INTO movies (title, year, description) VALUES (%s,%d,%s)"""
            inserted_values = (movie['title'], int(movie['year']), movie['info']['plot'])
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


def lambda_handler():
    with open("moviedata.json") as json_file:
        movie_list = json.load(json_file, parse_float=Decimal)
    load_data(movie_list)