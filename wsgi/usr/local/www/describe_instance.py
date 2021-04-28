import boto3   
import json
import os

def describe():
  #  os.system("TOKEN=$(curl -X PUT \"http://169.254.169.254/latest/api/token\" -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\")")
  #  os.system("curl -H \"X-aws-ec2-metadata-token: $TOKEN\" -v http://169.254.169.254/latest/meta-data/iam/security-credentials/website-demo > /tmp/credentials.json")

    ec2client = boto3.client(
        'ec2',
        'us-east-1'
    )
    # os.system("rm credentials.py")
    env = os.system("echo $ENVIRONMENT_NAME")
    response = ec2client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['website-(%s)' % env]
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
            output["State"] = instance["State"]
            output["Architecture"] = instance["Architecture"]

    #with open('output_file.json', 'w') as f:
    #    json.dump(output, f)
    #print(output)
    return(output)

