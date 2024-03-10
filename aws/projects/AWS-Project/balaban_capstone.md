- ### Step 1: Create dedicated VPC and whole components
- 1. create a vpc named "aws-capstone-VPC" with `90.90.0.0/16` CIDR
    - no ipv6 CIDR block
    - tenancy: default
- click create
- 2. enable DNS hostnames for the vpc 'aws-capstone-VPC'

  - select 'aws-capstone-VPC' on VPC console ----> Actions ----> Edit DNS hostnames  (edit vpc settings)
  - Click enable flag
  - Click save 
- 3. Create an internet gateway named 'aws-capstone-igw'
- Go to the Internet Gateways from left hand menu

- Create Internet Gateway
   - Name Tag "aws-capstone-igw" 
   - Click create button

-  attach the internet gateway 'aws-capstone-igw' to the vpc 'aws-capstone-VPC'
  - Actions ---> attach to VPC
  - Select VPC named "aws-capstone-VPC"
  - Push "Attach Internet gateway"
- 4. Create Subnets

- Go to the Subnets from left hand menu
- Push create subnet button

1. 
Name tag          :aws-capstone-az1a-public-subnet
VPC               :aws-capstone-VPC
Availability Zone :us-east-1a
IPv4 CIDR block   :90.90.10.0/24

2. 
Name tag          :aws-capstone-az1a-private-subnet
VPC               :aws-capstone-VPC
Availability Zone :us-east-1a
IPv4 CIDR block   :90.90.11.0/24

3. 
Name tag          :aws-capstone-az1b-public-subnet
VPC               :aws-capstone-VPC
Availability Zone :us-east-1b
IPv4 CIDR block   :90.90.20.0/24

4. 
Name tag          :aws-capstone-az1b-private-subnet
VPC               :aws-capstone-VPC
Availability Zone :us-east-1b
IPv4 CIDR block   :90.90.21.0/24

- 5. Route Tables
- create a private route table (not allowing access to the internet) 
  - name: 'aws-capstone-private-rt'
  - VPC : 'aws-capstone-VPC'
  - click create button

- show the routes in the route table clarus-private-rt,

- click Subnet association button and show the route table aws-capstone-private-rt with private subnets

- Click Edit subnet association
- select private subnets;
  - aws-capstone-az1a-private-subnet
  - aws-capstone-az1b-private-subnet
  - and click save

- create a public route table (allowing access to the internet) 

- push the create route table button
  - name: 'aws-capstone-public-rt'
  - VPC : 'aws-capstone-VPC'
  - click create button

- Click Edit subnet association

- select public subnets;
  - aws-capstone-az1a-public-subnet
  - aws-capstone-az1b-public-subnet
  - and click save

- select Routes on the sub-section of aws-capstone-public-rt

- click edit routes

- click add route

- add a route
    - destination ------> 0.0.0.0/0 (any network, any host)
    - As target;
      - Select Internet Gateway
      - Select 'aws-capstone-igw'
      - save routes  

- 6. enable Auto-Assign Public IPv4 Address for public subnets

- Go to the Subnets from left hand menu

  - Select 'aws-capstone-az1a-public-subnet' subnet ---> Action ---> edit subnet settings  ---> select 'Enable auto-assign public IPv4 address' ---> Save

  - Select 'aws-capstone-az1b-public-subnet' subnet ---> Action --->edit subnet settings  ---> select 'Enable auto-assign public IPv4 address' ---> Save

- 7. Create Endpoint

- go to the Endpoints menu on left hand pane in VPC

- click Create Endpoint
```text
Name             : aws-capstone-endpoint
Service Category : AWS services
Service Name     : com.amazonaws.us-east-1.s3  # search s3
Service Type     : gateway
VPC              : aws-capstone-VPC

- select aws-capstone-private-rt
- policy: Full access
- create endpoint
```
- ### Step 2: Create Security Groups (ALB ---> EC2 ---> RDS)

1. 
- Launch Template only allows HTTP (80) and HTTPS (443) ports coming from ALB Security Group and SSH (22) connections from anywhere.
- Application Load Balancer should be placed within a security group which allows HTTP (80) and HTTPS (443) connections from anywhere.  

Create Sec.Groups: # VPC: aws-capstone-VPC
   aws-capstone-ALB-sec-grp: In bound : "HTTP 80, HTTPS 443 > anywhere(0:/00000)"
   aws-capstone-RDS-sec-grp: In bound :"Mysql 3306 > from aws-capstone-EC2-sec-grp
   aws-capstone-NAT-sec-grp: In bound : "HTTP, HTTPS, SSH 22  > anywhere (0:/00000)" # No need for NAT-SG if you use NAT Gateway.
   aws-capstone-EC2-sec-grp: In bound : "HTTP, HTTPS (from AlB sec. grp.), SSH 22  > anywhere (0:/00000)"

- ### Step 3: Create RDS  
1. create subnet groups
- click subnet groups from the left-hand menu
    - name: aws-capstone-RDS-subnetgroup
    - Vpc: aws-capstone-VPC
    - selected subnets: - aws-capstone-az1a-private-subnet
                        - aws-capstone-az1b-private-subnet
- create

2.  Go to the Amazon RDS Service and select Database section from the left-hand menu, click databases and then click Creating Database.

- Choose a database creation method.

```text
Standard Create
```

- Engine option

```text
MySQL
```

- Version

```text
8.0.20
```

- Template

```text
Free tier
```

- Settings

```text
DB instance identifier: aws-capstone-rds
Master username: admin
Master password: "xxxxxxx"  # scr/cblog/.env
```

- DB instance class

```text
Burstable classes (includes t classes) : db.t2.micro
```

- Storage

```text
Storage type              : ssd
Storage size              : 20 GiB
Storage autoscaling       : disable
```

- Connectivity

```text
VPC                           : aws-capstone-VPC

Click Additional Connectivity Configuration;

Subnet group                  : aws-capstone-RDS-subnetgroup
*Publicly accessible          : No
Existing VPC security groups  : aws-capstone-RDS-sec-grp
Availability Zone             : No preference
Database port                 : 3306
```

- Database authentication

```text
DB Authentication: Password authentication
```

- Additional configuration

```text
Initial DB name                   : xxxxxxx
DB parameter group & option group : default
Automatic backups                 : enable
Backup retention period           : 7 days (Explain how)

Select window for backup to show snapshots
Monitoring  : Unchecked
Log exports : Unchecked

Maintenance
  - Enable auto minor version upgrade: Enabled (Explain what minor and major upgrade are)
  - Maintenance window (be careful not to overlap maintenance and backup windows)

Deletion protection: disable
```
- Click `Create Database` button

- ### Step 4: Create two S3 Buckets and set one of these as static website.
- Open S3 Service from AWS Management Console.
- Create 2 bucket with following properties, 
- First S3 Bucket

Bucket name                 : balabanblog
Region                      : N.Virginia
Object Ownership            : ACLs disabled
Block all public access     : Checked (KEEP BlOCKED)
Versioning                  : Disabled

- Second S3 Bucket

Bucket name                 : xxxxxxxxxxx  # we created it in advance
Region                      : N.Virginia
Object Ownership            : ACLs disabled
Block all public access     : Checked (KEEP BlOCKED)
Versioning                  : Disabled

  - Public Access "Enabled"
  - Upload Files named "index.html" and "sorry.jpg" in "s3.bucket.www" folder
  - Permissions>>> Bucket Policy >>> Paste bucket Policy
```bash
{
    "Version": "2012-10-17", 
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::don't forget to change me/*"
        }
    ]
}

```
  - Properties>>> Set Static Web Site >>> Enable >>> Index document : index.html 

- ### Step 5: Download or clone project definition from `Clarusway` repo on Github 
- ### Step 6: Prepare your Github repository 
do it after step8
- ### Step 7: Prepare a userdata to be utilized in Launch Template
```bash

#!/bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
git clone https://$TOKEN@github.com/balaban1432/private-my-projects
cd /home/ubuntu/private-my-projects/Capstone-Project
apt install python3-pip -y
apt-get install python3.7-dev default-libmysqlclient-dev -y
pip3 install -r requirements.txt
cd /home/ubuntu/private-my-projects/Capstone-Project/src
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80

```
- ### Step 8: Write RDS, S3 in settings file given by Clarusway Fullstack Developer team 

settings file içindeki RDS ve S3 bilgileri kaynaklar oluşturulduktan sonra doldurulacak

- ### Step 9: Create NAT Instance in Public Subnet
- You might create new instance as Bastion host on Public subnet or you can use NAT instance as Bastion host.

1.  Create NAT Instance

- Go to EC2 Menu Using AWS Console

```text
AMI             : ami-0aa210fd2121a98b7 (Nat Instance)
Instance Type   : t2.micro
Network         : aws-capstone-VPC
Subnet          : aws-capstone-az1a-public-subnet
Security Group  : aws-capstone-NAT-sec-grp

Tag             :
    Key         : Name
    Value       : aws-capstone-NAT-bastion
```

- Select created Nat Instance on EC2 list

- Tab Actions Menu ----> Networking ----> Change Source/Destination Check ---> stop

2. Configuring the Route Table

- Go to Route Table and select "aws-capstone-private-rt"
- Add Route
```
Destination     : 0.0.0.0/0
Target ----> Instance ----> Nat Instance
```
3. if we want to connect web server we will do following steps:
- eval "$(ssh-agent)"
- ssh-add KEY_NAME_HERE.pem  # Be careful about the path of your key, use relative or absolute path.
- ssh -A ec2-user@3.88.199.43 # Don't forget to change the IP with your instance IP.
- ssh ubuntu@10.7.2.20 (Private IP of webserver) # Don't forget to change the IP with your instance IP.

- ### Step 10: Create Launch Template and IAM role for it
1.  Create 2 IAM Role:

Go to IAM page.

- Go to `Roles` on the left hand menu and click `create role`.
- first role
```text
Type of Trusted Entity      : AWS Service
Use Case                    : EC2
Permissions                 : AmazonS3FullAccess 
Name:                       : aws-capstone-EC2-S3-role
```
- second role
- Since Lambda needs to talk S3 and DynamoDB and to run on created VPC, S3, DynamoDB full access policies and NetworkAdministrator policy must be attached it
```text
Type of Trusted Entity      : AWS Service
Use Case                    : Lambda
Permissions                 : - AmazonS3FullAccess
                              - NetworkAdministrator
                              - AmazonDynamoDBFullAccess                 
Name:                       : aws-capstone-Lambda-role
```

2. You should create Application Load Balancer with Auto Scaling Group of Ubuntu 18.04 EC2 Instances within created VPC.
- Launch Template Name

```text
Launch template name            : aws-capstone-LT
Template version description    : V1
Autoscaling Guidance            : Enable
```

- Amazon Machine Image (AMI)

```text
Ubuntu, 18.04 LTS (us-east-1)
```

- Instance Type

```text
t2.micro
```

- Key Pair

```text
Please select your key pair (pem key)
```

- Network settings

```text

```

- Security groups

```text
aws-capstone-EC2-sec-grp
```

- Storage (volumes)

```text
Keep it as default (Volume 1 (AMI Root) (8 GiB, EBS, General purpose SSD (gp2)))
```

- Resource tags

```text
Key             : Name
Value           : capstone-web-server
Resource type   : Instance
```

- Network interfaces

```text
Keep it as it is
```

- Within `Advanced details` section,
- IAM instance profile          : aws-capstone-EC2-S3-role
- we will just use `user data` settings. Please paste the script below into the `user data` field.

```bash

#!/bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
git clone https://$TOKEN@github.com/balaban1432/private-my-projects
cd /home/ubuntu/private-my-projects/Project-503-Capstone-Project
apt install python3-pip -y
apt-get install python3.7-dev default-libmysqlclient-dev -y
pip3 install -r requirements.txt
cd /home/ubuntu/private-my-projects/Project-503-Capstone-Project/src
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80

```
- Click Create Launch template

- ### Step 11: Create certification for secure connection
- Get Certificate with AWS Certification Manager Configuration

- ### Step 12: Create ALB and Target Group

1. Create Target Group

- Go to `Target Groups` section under the Load Balancing part on left-hand menu and select `Target Group`

- Click `Create Target Group` button

  - Basic configuration

    ```text
    Choose a target type    : Instances
    Give Target Groups Name : awscapstoneTargetGroup
    Protocol                : HTTP
    Port                    : 80
    VPC                     : aws-capstone-VPC
    ```

  - Health checks

    ```text
    Health check protocol   : HTTP
    Health check path       : /
    ```

  - Advance health check settings

    ```text
    Port                    : Traffic port
    Healthy threshold       : 3
    Unhealthy threshold     : 2
    Timeout                 : 5 seconds
    Interval                : 10 seconds
    Success codes           : 200
    ```
- Click next
- Click `Create Target Group` button.

2. Create Load Balancer

- Click `Create Load Balancer` tab.

- Select the `Application Load Balancer` option.

- Configure Load Balancer
- Name            : aws-capstone-ALB
- Network mapping
  -- VPC: aws-capstone-VPC
  -- select - aws-capstone-az1a-public-subnet
            - aws-capstone-az1b-public-subnet
- Select an existing security group : aws-capstone-ALB-sec-grp

- Listeners       : A listener is a process that checks for connection requests, using the protocol and port that you configured.

Protocol      : HTTPS
Port          : 443
Action        : Forward
Target Group  : awscapstoneTargetGroup

- Secure listener setting
From ACM  --- choose your certificate

- Review and if everything is ok, click the `Create` button.

- click load balancer
- select listeners tab and add listener
- listener details
    protocol : HTTP
    Port : 80
    add Action : Redirect
    protocol : HTTPS
    Port : 443
- Add

- ### Step 13: Create Autoscaling Group with Launch Template

- EC2 AWS Management console, select Auto Scaling Group from the left-hand menu and then click Create Auto Scaling Group

- Name: aws-capstone-ASG
- launch template : aws-capstone-LT
- next
- VPC : aws-capstone-VPC
- Subnets : Select private subnets
- next
- Attach to an existing load balancer
- awscapstoneTargetGroup
- set health check grace period to  ` 200 seconds`
- set health check type to  ` ELB`
- next
- set desired capacity of instances to  ` 2`
- set minimum size of instances to  ` 2`
- set maximum size of instances to  ` 4`
- Scaling Policy --> Target Tracking Policy
- Average CPU utilization (set Target Value ` %70`)
- seconds warm up before including in metric ---> `200`
- next
- add notification
- create a topic
     - input your email
     - select all events
- next
- next
- create
- ### Step 14: Create Cloudfront in front of ALB
- ### Step 15: Create Route 53 with Failover settings

1. - Go to CloudFront service and click "Create a CloudFront Distribution"

- Create Distribution :
  - Origin:
    - Origin Domain: choose ALB
  - Default Cache Behavior:
    - Viewer Protocol Policy: Select "Redirect HTTP to HTTPS" 
    - GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE methods should be allowed.
    - Forward Cookies must be selected All.
  - Settings
    - Alternate Domain Names (CNAME): [your-domain-name]
    - Custom SSL Certificate: Select your newly created certificate

- Leave the other settings as default.

- Click "Create Distribution".

- It may take some time distribution to be deployed. (Check status of distribution to be "Enabled")

- When it is deployed, copy the "Domain name" of the distribution. 

2. - Healthcheck should check If Cloudfront is healthy or not.
- - Go to left hand pane and click the Health check menu 

- Click Health check button

- Create Health Check

Name: awscapstonehealthcheck

What to monitor     : Endpoint

Specify endpoint by : Domain name of cloudfront  # cloudfront distribution sorunu yaşayanlar ALB ye direk bağlayabilir

Protocol            : HTTP

Domain Name         : Write cloudfront domain name

Hostname:           : -

Port                : 80

Path                : leave it as /

Advance Configuration 

Request Interval    :  Standard (30seconds)  # fast paralı

Failure Threshold   : 3

Explain Response Time:

String Matching     : No 

Latency Graphs:     : Keep it as is

Invert Health Check Status: Keep it as is

Health Checker Regions: Keep it as default
click Next
Get Notification   : None
create health check


3. Create A record for  cloudfront or ALB Domain Name - Primary record

- Click create record

- select "Failover" as a routing policy

```bash
Record Name :"www"  # same as my bucket name
Record Type : A
TTL:"60"
- enable Alias
Value/Route traffic to :  cloudfront or ALB
Routing: "Failover"
Failover record type    : Primary
Health check            : awscapstonehealthcheck
Record ID               : Failover Scenario-primary
```
- push the create records button

4. Create A record for S3 website endpoint - Secondary record

- Click create record

- select "Failover" as a routing policy

```bash
Record Name :"www"
Record Type : A
TTL:"60"
Value/Route traffic to : 
  - "Alias to S3 website endpoint"
  - N.Virginia(us-east-1)
  - Choose your S3 bucket named "www.[your sub-domain name].net"
Routing: "Failover" 
Failover record type    : Secondary
Health check            : keep it as is
Record ID               : Failover Scenario-secondary
```
- push the create records button

- ### Step 16: Create DynamoDB Table
- ### Step 17-18: Create Lambda function 

- Step 17-18: Create S3 Event and set it as trigger for Lambda Function

- DynamoDB Table
  - Create a DynamoDB table which has primary key that is `id`
  - Created DynamoDB table's name should be placed on Lambda function.

1. Creating DynamoDB Tables

- Go to `DynamoDB` service on AWS console.

- Click `Create Table`. 

- Set table name as `awscapstoneDynamo`.

- Set Partition Key as `id` and select the type of key as `string`. No Sort Key.

- Leave other settings default.

- Click `Create`.

2. Create Lambda Function

- Go to Lambda Service on AWS Console

- Functions ----> Create Lambda function
```text
1. Select Author from scratch
  Name: awscapstonelambdafunction
  Runtime: Python 3.8
  Role: aws-capstone-Lambda-role

2. Advance Setting:
   Network                 : 
    - VPC               : aws-capstone-VPC
    - Subnets           : Select all subnets
    - Security Group    : Select default security Group
  
```

3. Setting Trigger Event

- Go to Configuration sub-menu and click AddTrigger on Designer  
```
Trigger Configuration : S3

- Bucket              : balabanblog  # unequal

- Event Type          : All object create events

- Acknowledge         : checked 
- Add
```

4. Create Function Code

- Go to the Function Code sub-menu and paste code seen below:

```python
import json
import boto3

def lambda_handler(event, context):
    s3 = boto3.client("s3")
    
    if event:
        print("Event: ", event)
        filename = str(event['Records'][0]['s3']['object']['key'])
        timestamp = str(event['Records'][0]['eventTime'])
        event_name = str(event['Records'][0]['eventName']).split(':')[0][6:]
        
        filename1 = filename.split('/')
        filename2 = filename1[-1]
        
        dynamo_db = boto3.resource('dynamodb')
        dynamoTable = dynamo_db.Table('awscapstoneDynamo')
        
        dynamoTable.put_item(Item = {
            'id': filename2,
            'timestamp': timestamp,
            'Event': event_name,
        })
        
    return "Lammda success"
```
- Click "DEPLOY" button