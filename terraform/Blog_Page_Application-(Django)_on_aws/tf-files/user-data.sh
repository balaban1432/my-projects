#!/bin/bash
apt-get update -y
apt-get upgrade -y
apt-get install git -y
apt-get install python3 -y
apt install python3-pip -y
pip3 install boto3
apt  install awscli -y
cd /home/ubuntu/
echo "${db-endpoint}" > /home/ubuntu/dbserver.endpoint
TOKEN=$(aws --region=us-east-1 ssm get-parameter --name /${user}/capstone/token --with-decryption --query 'Parameter.Value' --output text)
git clone https://$TOKEN@github.com/${githubname}/aws-capstone-project.git
cd /home/ubuntu/aws-capstone-project
apt-get install python3.10-dev default-libmysqlclient-dev -y 
pip3 install -r requirements.txt
cd /home/ubuntu/aws-capstone-project/src/cblog
sed -i "s|username_param = ssm.get_parameter(Name='/<yourname>/capstone/username', WithDecryption=True)|username_param = ssm.get_parameter(Name='/${user}/capstone/username', WithDecryption=True)|g" settings.py
sed -i "s|password_param = ssm.get_parameter(Name='/<yourname>/capstone/password', WithDecryption=True)|password_param = ssm.get_parameter(Name='/${user}/capstone/password', WithDecryption=True)|g" settings.py
sed -i "s|AWS_STORAGE_BUCKET_NAME = '' # please enter your s3 bucket name|AWS_STORAGE_BUCKET_NAME = '${bucketname}'|g" settings.py
cd /home/ubuntu/aws-capstone-project/src
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80