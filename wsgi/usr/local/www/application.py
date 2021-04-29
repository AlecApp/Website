from flask import Flask, render_template, request, make_response, jsonify, json
import query_db, decimal, describe_instance, cluster_demo

#Create Flask application. Note that Elastic Beanstalk (which was my testing environment) requires the application to be named "application" not "app".
application = Flask(__name__)

#This is a decorator. It defines what HTTP requests should be grabbed by the following function.
@application.route('/', methods=["GET"])
def hello():
    return render_template('index.html')

@application.route('/launchcluster', methods=["GET"])
def launchKubernetesDemo():
    data = cluster_demo.createDemo()
    return "Attempted To Launch Cluster"
 
@application.route('/checkcluster', methods=["GET"])
def checkKubernetesDemo():
    data = cluster_demo.describeCluster()
    return data
    
@application.route('/instanceinfo', methods=["GET"])
def getInstanceInfo():
    info = describe_instance.describe()
    return (json.dumps(info))

@application.route('/movies', methods=["GET", "POST"])
def getMovies():
    
    #Get list of movies matching queried year
    movies = query_db.query_movies(int(request.form["year"]))
    
    # Old Code to sanitize release date

    #Sanitize that list (to convert the Decimal data type that json.dumps() can't convert into a Float string that it can.)
    #Go through several layers of dictionaries to reach nested Decimal data.
    # for movie in movies:
    #    for key in movie.keys():
    #        if isinstance(movie[key], decimal.Decimal):
    #            movie[key] = float(movie[key])
    #        elif isinstance(movie[key], dict):
    #            for key_2 in movie[key].keys():
    #                if isinstance(movie[key][key_2], decimal.Decimal):
    #                    movie[key][key_2] = float(movie[key][key_2])
    
    #Return JSON string of movie data
    return (json.dumps(movies))                      

if __name__ == "__main__":
    application.debug = False
    application.run()
