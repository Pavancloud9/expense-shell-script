#!/bin/bash

ROOTID=$(id -u)
if [ $ROOTID -ne 0 ]
then
    echo "ERROR:: You must have sudo access to execute this script"
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo "$2...FAILURE"
        exit 1
    else
        echo "$2...SUCCESS"
    fi
}

LOGS_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>>$LOG_FILE_NAME

############

dnf list installed nginx  &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    dnf install nginx -y  &>>$LOG_FILE_NAME
    VALIDATE $? "Installing nginx"
else
    echo "Nginx already installed...SKIPPING"
fi

systemctl enable nginx
VALIDATE $? "Enabing Nginx"

systemctl start nginx
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing nginx default page"

    