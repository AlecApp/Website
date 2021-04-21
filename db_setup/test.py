import boto3

def test():
    client = boto3.client('sts')
    id = client.get_caller_identity()
    print(id)

test()