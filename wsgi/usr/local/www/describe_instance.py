import boto3   
import json
import os

def describe():
    # Note that attempting to get auth credentials from the instance metadata will fail (b/c Docker). Instead, I'm passing the creds as environment variables in the startup script.
    ec2client = boto3.client(
        'ec2',
        'us-east-1'
    )
    env = os.environ.get('ENVIRONMENT_NAME')
    # Note that 'website-%s' % env does NOT work. Use a different method of formatting the string. Concat e.g. s + s and the .format() method both work.
    response = ec2client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['website-{0}'.format(env)]
            },
            {
                'Name': 'instance-state-name',
                'Values': ['running']
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
            output["PublicIpAddress"] = instance["PublicIpAddress"]
            output["State"] = instance["State"]
            output["Architecture"] = instance["Architecture"]

    # with open('/tmp/output.json', 'w') as f:
    #    json.dump(output, f)
    
    return(output)