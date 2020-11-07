#This script uses code from the AWS tutorial on Python and DynamoDB interactions
#found here: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStarted.Python.html
#The code has been slightly tweaked and commented to show that I understand it.
#The "Movies" database used was created using code from that tutorial. (I haven't included it here for that reason.)

import boto3
from boto3.dynamodb.conditions import Key

def query_movies(year, dynamodb=None):

    #If no DynamoDB resource was specified, set our DynamoDB database to be the one in us-east-1.
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

    #Retrieve our "Movies" table and query it for movies whose "year" field matches our year variable.
    table = dynamodb.Table('Movies')
    response = table.query(
            KeyConditionExpression=Key('year').eq(year)
    )
    
    #return our list of movie data objects
    return response['Items']
