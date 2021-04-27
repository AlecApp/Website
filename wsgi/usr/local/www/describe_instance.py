import boto3   
import json
import os

def describe():
    os.system("TOKEN=$(curl -X PUT \"http://169.254.169.254/latest/api/token\" -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\")")
    os.system("curl -H \"X-aws-ec2-metadata-token: $TOKEN\" -v http://169.254.169.254/latest/meta-data/iam/security-credentials/website-demo > /tmp/credentials.json")

    ec2client = boto3.client(
        'ec2',
        'us-east-1',
        aws_access_key_id=os.system("cat /tmp/credentials.json | jq .AccessKeyId"),
        aws_secret_access_key=os.system("cat /tmp/credentials.json | jq .SecretAccessKey"),
        aws_session_token=os.system("cat /tmp/credentials.json | jq .Token")
    )
    # os.system("rm credentials.py")
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

