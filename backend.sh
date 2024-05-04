#!/bin/bash

source ./common.sh
check_root

echo "Please enter DB password:"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE  $? "Disabling default NodeJS"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE  $? "enabling default NodeJS"

dnf install nodejs -y &>>$LOGFILE
VALIDATE  $? "Installing NodeJS"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE  $? "Create user expense"
else
    echo -e "expense user already exist..$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE  $? "Create app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE  $? "Downloading Backend Code"

cd /app 
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE  $? "Extracted Backend Code"

npm install &>>$LOGFILE
VALIDATE  $? "Installing NodeJS Dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE  $? "Copied backed services"

systemctl daemon-reload &>>$LOGFILE
VALIDATE  $? "starting demon reload"

systemctl start backend &>>$LOGFILE
VALIDATE  $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE  $? "enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE  $? "Installing mysql client"

mysql -h db.kalyaneswar.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE  $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE  $? "Restart Backend"

# systemctl status backend
# netstat -lntp
