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

check_root(){
    if [ $USERID -ne 0 ]
    then
        echo "Please run this script with root access."
        exit 1 # manually exit if error comes.
    else
        echo "You are super user."
    fi
}
