import boto3   
import json

def describe():
    ec2client = boto3.client('ec2','us-east-1')
    response = ec2client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['Website']
            }
        ]
    )
    output = {}
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            #for element in instance:
             #   output.append(element)
            output["ImageId"] = instance["ImageId"]
            output["InstanceType"] = instance["InstanceType"]
            output["Monitoring"] = instance["Monitoring"]
            output["PublicDnsName"] = instance["PublicDnsName"]
            output["PublicIpAddress"] = instance["PublicIpAddress"]
            output["State"] = instance["State"]
            output["Architecture"] = instance["Architecture"]

    #with open('output_file.json', 'w') as f:
    #    json.dump(output, f)
    #print(output)
    return(output)
