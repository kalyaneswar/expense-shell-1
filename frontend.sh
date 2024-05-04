#!/bin/bash

source ./common.sh
check_root

dnf install nginx -y &>>$LOGFILE
VALIDATE  $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE  $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE  $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE  $? "Removing Existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE  $? "Downloading Frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE  $? "Upziping frontend code"

cp /home/ec2-user/expense-shell-1/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE  $? "Copying expense config"

systemctl restart nginx &>>$LOGFILE
VALIDATE  $? "Restarting Nginx"