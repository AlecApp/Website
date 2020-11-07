import boto3   
import json

def describe():

    #create boto3 client for EC2, region us-east-1
    ec2client = boto3.client('ec2','us-east-1')
    
    #Retrieve a list of all active instances filtered by a name tag "Website" (Which returns only one instance—our website server)
    response = ec2client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['Website']
            }
        ]
    )
    
    #Create an empty dictionary to store our return values.
    output = {}
    
    #Loop through returned instances from our query, adding their relevant data into our dictionary as Key/Value pairs.
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            output["ImageId"] = instance["ImageId"]
            output["InstanceType"] = instance["InstanceType"]
            output["Monitoring"] = instance["Monitoring"]
            output["PublicDnsName"] = instance["PublicDnsName"]
            output["PublicIpAddress"] = instance["PublicIpAddress"]
            output["State"] = instance["State"]
            output["Architecture"] = instance["Architecture"]
    
    #Return the dictionary we just built.
    return(output)

