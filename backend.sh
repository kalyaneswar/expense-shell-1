#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
# R="\e[31m"
# G="\e[32m"
# N="\e[0m"
# Y="\e[33m"
R=$(tput setaf 1)
G=$(tput setaf 2)
N=$(tput sgr0)
Y=$(tput setaf 3)

echo "Please enter DB password:"
read -s mysql_root_password

VALIDATE(){
    # echo "Exist status: $1"
    # echo "What are you doing : $2"
    if [ $1 -ne 0 ]
    then
        echo "$2..$R FAILURE $N"
        exit 1
    else
        echo "$2..$G SUCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

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
