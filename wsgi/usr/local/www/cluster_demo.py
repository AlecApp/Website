import boto3
import fileinput
import json
import time

def createDemo():
    
    #Store an incrementing variable in a JSON text file.
    with open("/usr/local/www/variables.txt") as f:
        variables = json.load(f)
    variables["count"] = variables["count"] + 1
    with open("/usr/local/www/variables.txt", "w") as f:
        json.dump(variables, f)
    
    #Use that variable to give the created resources unique names and tags.
    cluster_name = "demo-cluster-" + str(variables["count"])
    group_name = "EKS-Demo-" + str(variables["count"])

    client = boto3.client("ec2", "us-east-1")
    
    #Create a VPC for the demo cluster
    cluster_vpc = client.create_vpc(
            CidrBlock="192.168.0.0/16",
            TagSpecifications=[
                {
                    "ResourceType": "vpc",
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": group_name + "-VPC"
                        },
                        {
                            "Key": "Group",
                            "Value": group_name
                        },
                    ]
                },
            ]
        )
    vpc_id = cluster_vpc["Vpc"]["VpcId"]
    
    #Wait until that VPC is no longer "pending" but "active".
    cluster_vpc = client.describe_vpcs(
                VpcIds=[
                    vpc_id
                ]
            )
    while cluster_vpc["Vpcs"][0]["State"] == "pending":
        cluster_vpc = client.describe_vpcs(
                VpcIds=[
                    vpc_id
                 ]
            )

    #Then create two subnets in that VPC in separate Availability Zones.
    cluster_subnet_0 = client.create_subnet(
            AvailabilityZone="us-east-1a",
            CidrBlock="192.168.1.0/24",
            VpcId=cluster_vpc["Vpcs"][0]["VpcId"],
            TagSpecifications=[
                {
                    "ResourceType": "subnet",
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": group_name + "-Subnet_0"
                            },
                        {
                            "Key": "Group",
                            "Value": group_name
                            },
                        ]
                    },
                ]
            )

    cluster_subnet_1 = client.create_subnet(
            AvailabilityZone="us-east-1b",
            CidrBlock="192.168.3.0/24",
            VpcId=cluster_vpc["Vpcs"][0]["VpcId"],
            TagSpecifications=[
                {
                    "ResourceType": "subnet",
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": group_name + "-Subnet-1"
                            },
                        {
                            "Key": "Group",
                            "Value": group_name
                            },
                        ]
                    },
                ]
            )
    
    #Wait for the subnets to be created.
    x = False
    while x == False:
        cluster_subnets = client.describe_subnets(
                    SubnetIds=[
                            cluster_subnet_0["Subnet"]["SubnetId"],
                            cluster_subnet_1["Subnet"]["SubnetId"]
                        ]
                    )
        x = True
        for subnet in cluster_subnets["Subnets"]:
            if subnet["State"] == "pending":
                x = False

    
    #Change boto3 client to EKS (from EC2) to use eks-related commands.
    client = boto3.client("eks", "us-east-1")

    #Identify the Kubernetes cluster's role and the subnets it will use.
    cluster_role = "arn:aws:iam::821196369224:role/APA-EKSDemoClusterRole"

    cluster_vpc_config = {
                "subnetIds": [
                        cluster_subnet_0["Subnet"]["SubnetId"],
                        cluster_subnet_1["Subnet"]["SubnetId"]
                    ]
            }
    
    #Create the cluster.
    cluster = client.create_cluster(
            name=cluster_name,
            roleArn=cluster_role,
            resourcesVpcConfig=cluster_vpc_config,
            tags={
                "Group": group_name
                }
            )
    
    #Wait for the cluster to finish creating and reach its "ACTIVE" state.
    x = False
    while x == False:
        cluster = client.describe_cluster(name=cluster["cluster"]["name"])
        if cluster["cluster"]["status"] == "ACTIVE":
            x = True
            print("Cluster Active")
    
    #Pause for 30 minutes
    time.sleep(1800)
    
    #Then delete the demo
    deleteDemo(group_name)
    
    #Return generic "OK"
    return 1

def deleteDemo(group_name):
    
    #Delete resources in reverse order of creation: Cluster, Subnets, VPC
    client = boto3.client("eks", "us-east-1")
    clusters = client.list_clusters()
    
    #Cycle through all clusters, checking their "Group" tags for a match with group_name.
    for cluster_name in clusters["clusters"]:
        cluster = client.describe_cluster(name=cluster_name)
        try:
            if cluster["cluster"]["tags"]["Group"] == group_name:
                deleting = client.delete_cluster(name=cluster_name)
    
                #Wait for the cluster to fully detach and delete.
                #For some reason, the Python code will continue before the cluster is fully deleted
                #unless this loop is used to wait for the ResourceNotFoundException error.
                x = False
                while x == False:
                    try:
                        cluster = client.describe_cluster(name=cluster_name)
                        time.sleep(2)
                    except client.exceptions.ResourceNotFoundException as e:
                        x = True
        except:
            print("Skipped Cluster: Did not have matching group tag.")
    
    #Switch client to EC2, for subnet and vpc commands.
    client = boto3.client("ec2", "us-east-1")
    
    #Get list of subnets with matching "Group" tag.
    subnets = client.describe_subnets(
        Filters=[
            {
                "Name": "tag:Group",
                "Values": [
                    group_name,
                ]
            },
        ]
    )
    
    #Delete subnets
    for subnet in subnets["Subnets"]:
        try:
            client.delete_subnet(SubnetId=subnet["SubnetId"])
            print(subnet["SubnetId"])
        except:
            print("Unknown error when attempting to delete subnet.")
       
    #Get VPCs with matching "Group" tags.
    vpc_list = client.describe_vpcs()
    for vpc in vpc_list["Vpcs"]:
        try:
            for tag in vpc["Tags"]:
                if tag["Key"] == "Group" and tag["Value"] == group_name:
                    client.delete_vpc(VpcId=vpc["VpcId"])
                    break;
        except KeyError:
            print("Ignored VPC: No matching tags found.")
    
    #Return generic "OK"
    return 1
            

def describeCluster():

    #Get EKS client for EKS commands.
    client = boto3.client("eks", "us-east-1")
    
    #Lust clusters in the client's region. Create empty list to store cluster data objects
    clusters = client.list_clusters()
    data = []
    
    #Search list for clusters with matching "Group" tags. Append a dictionary containing their properties to our data list.
    for cluster_name in clusters["clusters"]:
        cluster = client.describe_cluster(name=cluster_name)
        try:
            if "EKS-Demo" in cluster["cluster"]["tags"]["Group"]:
                data_object = {
                    "name": cluster["cluster"]["name"],
                    "createdAt": str(cluster["cluster"]["createdAt"]),
                    "status": cluster["cluster"]["status"]
                }
                data.append(data_object)
        except:  
            print("Error when attempting to return dict of cluster data.")
            
    #Return a JSON string containing our data list and the dictionary objects in it.
    return (json.dumps(data))
    
