sh
#!/bin/bash

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB system..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

if [ ! -f "/var/lib/mysql/.db_initialized" ]; then
    echo "Creating WordPress database and user..."

    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    touch /var/lib/mysql/.db_initialized
    echo "WordPress database setup complete."
fi

exec mysqld --user=mysql --console