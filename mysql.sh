#!/bin/bash

source ./common.sh
check_root()

echo "Please enter DB password:"
read -s mysql_root_password

# Install MySQL Server 8.0.x
dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySql server"

# Start MySQL Service
systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySql server"
systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Start MySql server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root  MySql passwd"

# Below code is useful for idempotency nature
mysql -h db.kalyaneswar.online -uroot -p${mysql_root_password} -e 'SHOW DATABASES;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "Setting up root password"
else
    echo -e "MySQL root password is already setup..$Y SKIPPING $N"
fi


