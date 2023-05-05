#! /bin/bash
yum update -y
yum install python3 -y
pip3 install flask
pip3 install flask_mysql
yum install git -y
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
cd /home/ec2-user && git clone https://$TOKEN@github.com/balaban1432/phonebook.git
echo "${db-endpoint}" > /home/ec2-user/phonebook/dbserver.endpoint
python3 /home/ec2-user/phonebook/phonebook-app.py