#!/bin/bash

source ./common.sh
check_root

echo "Please enter DB password:"
read -s mysql_root_password

# Install MySQL Server 8.0.x
dnf install mysql-server -y &>>$LOGFILE

# Start MySQL Service
systemctl enable mysqld &>>$LOGFILE
systemctl start mysqld &>>$LOGFILE


# Below code is useful for idempotency nature
mysql -h db.kalyaneswar.online -uroot -p${mysql_root_password} -e 'SHOW DATABASES;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
else
    echo -e "MySQL root password is already setup..$Y SKIPPING $N"
fi


