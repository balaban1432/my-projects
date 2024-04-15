WARNING!!!

- Create an demo amazon Linux 2023 EC2 instance then First check the aws version

```bash
aws --version
```

- Write your credentials using this command
```bash
aws configure
```

- or Assign a role with AdministratorFullAccess Policy. It is best practice to use IAM role rather than using AWS credentials

1. Create Security Group

```bash
aws ec2 create-security-group \
    --group-name roman_numbers_sec_grp \
    --description "This Sec Group is to allow ssh and http from anywhere"
```

- We can check the security Group with these commands
```bash
aws ec2 describe-security-groups --group-names roman_numbers_sec_grp
```

2. Create Rules of security Group

```bash
aws ec2 authorize-security-group-ingress \
    --group-name roman_numbers_sec_grp \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name roman_numbers_sec_grp \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name roman_numbers_sec_grp \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0
```

- We can check the security Group with these commands again 
```bash
aws ec2 describe-security-groups --group-names roman_numbers_sec_grp
```

3. After creating security Groups, We'll create our EC2 which has latest AMI id. to do this, we need to find out latest AMI with AWS system manager (ssm) command

- This command is to run querry to get latest AMI ID
```bash
aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query 'Parameters[0].[Value]' --output text
```

- We can assign this latest AMI id output to the LATEST_AMI environmental variable and use in our CLI command 

```
(LATEST_AMI=xxxxxxxxxxxxxxxx)
```
- or we can directly fetch the last version via  using "resolve:ssm". We keep going with using "resolve:ssm" option. 

- in home directory of Ec2 create a userdata.sh file with following

```
#! /bin/bash
dnf update -y
dnf install python3 -y
dnf install python3-pip -y
pip3 install flask
dnf install git -y
cd /home/ec2-user
FOLDER="https://raw.githubusercontent.com/awsdevopsteam/roman-number-conventor/main"
wget -P templates ${FOLDER}/templates/index.html
wget -P templates ${FOLDER}/templates/result.html
wget ${FOLDER}/roman-numerals-converter-app.py
python3 roman-numerals-converter-app.py
```
- As for the student who use his/her own local terminal, they need to show the absulete path of userdata.sh file

- Now we can run the instance with CLI command. (Do not forget to create userdata.sh under "/home/ec2-user/" folder before run this command)

```bash
aws ec2 run-instances --image-id $LATEST_AMI --count 1 --instance-type t2.micro --key-name osvaldo --security-groups roman_numbers_sec_grp --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roman_numbers}]' --user-data file:///Users/ODG/Desktop/git_dir/osvaldo-cw/porfolio_lesson_plan/week_6/CLI_solution/userdata.sh

or

aws ec2 run-instances \
    --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --count 1 \
    --instance-type t2.micro \
    --key-name osvaldo \
    --security-groups roman_numbers_sec_grp \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roman_numbers}]'\
    --user-data file:///home/ec2-user/userdata.sh
```

- To see the each instances Ip we'll use describe instance CLI command
```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=roman_numbers"
```

- You can run the query to find Public IP and instance_id of instances:
```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=roman_numbers" --query 'Reservations[].Instances[].PublicIpAddress[]' --output text

aws ec2 describe-instances --filters "Name=tag:Name,Values=roman_numbers" --query 'Reservations[].Instances[].InstanceId[]' --output text
```

- To delete instances
```bash 
aws ec2 terminate-instances --instance-ids <We have already learned this id with query on above>
```
- To delete security groups
```bash
aws ec2 delete-security-group --group-name roman_numbers_sec_grp
```
