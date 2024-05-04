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

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE  $? "Copying expense config"

systemctl restart nginx &>>$LOGFILE
VALIDATE  $? "Restarting Nginx"