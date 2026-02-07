#!/bin/bash

USERID=$(id -u)
if [ $USERID -ne 0 ]
then
    echo "ERROR:: you must have sudo access to execute this script"
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo "$1....FAILURE"
        exit 1
    else
        echo "$2....SUCCESS"
    fi
}

###############################################

LOGS_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log" 

##############

dnf module disable nodejs -y
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodejs-20"

dnf install nodejs -y
VALIDATE $? "Installing nodejs"

useradd expense
VALIDATE $? "creating expense user"

mkdir /app
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading application code"

cd /app

unzip /tmp/backend.zip
VALIDATE $? "Unzipping backend code"

npm install
VALIDATE $? "Installing dependencies"

