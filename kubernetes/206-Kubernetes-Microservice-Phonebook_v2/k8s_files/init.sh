MYSQL_ROOT_PASSWORD="R123456b"
MYSQL_DATABASE="phonebook"
MYSQL_USER="balaban"
MYSQL_PASSWORD="Rb123456"

MYSQL_DATABASE_HOST="mysql-service"

# where to store data mysql serevr:
/var/lib/mysql

kubectl create secret generic mysql-secret --from-literal=MYSQL_ROOT_PASSWORD="R123456b" --from-literal=MYSQL_PASSWORD="Rb123456" --dry-run=client -o yaml > mysql-secret.yaml

