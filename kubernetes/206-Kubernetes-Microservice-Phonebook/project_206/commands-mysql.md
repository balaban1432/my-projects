# for db-server
mysql -u admin -p
SHOW DATABASES;
USE phonebook
SHOW TABLES;
SELECT * FROM phonebook;




# for client
apk add --no-cache mysql-client
mysql -u admin -p -h mysql-service
SHOW DATABASES;
USE phonebook
SHOW TABLES;
SELECT * FROM phonebook;