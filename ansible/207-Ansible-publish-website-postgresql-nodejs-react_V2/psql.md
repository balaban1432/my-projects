
``````psql
sudo yum install postgresql
psql -h <host> -p <port> -d <database> -U <username>
psql -h 54.81.213.92 -p 5432 -d clarustodo -U postgres
SELECT * FROM pg_tables WHERE schemaname = 'public'; # tüm table leri göster
SELECT * FROM todo;
