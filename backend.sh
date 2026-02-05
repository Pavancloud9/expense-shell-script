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

echo "Script started executing at $TIMESTAMP" &>>$LOG_FILE_NAME

dnf module disable nodejs -y  &>>$LOG_FILE_NAME
VALIDATE $? "Disabling NodeJs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE_NAME
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y  &>>$LOG_FILE_NAME
VALIDATE $? "Installing NodeJS"

useradd expense
VALIDATE $? "Adding expense user"

mkdir /app
VALIDATE $? "Creating App directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading Application code"

cd /app

unzip /tmp/backend.zip 
VALIDATE $? "Unzipping backend code"

npm install  &>>$LOG_FILE_NAME
VALIDATE $? "Installing Dependencies"

cp /home/ec2-user/expense-shell-script/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql-client"

mysql -h mysql.pavancloud5.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Loading schema to DB"

systemctl daemon-reload
VALIDATE $? "Daemon-reload"

systemctl restart backend
VALIDATE $? "Restarting backend"






