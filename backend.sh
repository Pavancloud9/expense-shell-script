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

dnf module disable nodejs -y   &>>$LOG_FILE_NAME
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE_NAME
VALIDATE $? "Enabling nodejs-20"

dnf install nodejs -y    &>>$LOG_FILE_NAME
VALIDATE $? "Installing nodejs"

id expense  &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "Creating expense user"
else
    echo "Expense user already created...SKIPPING"
fi

mkdir -p /app
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading application code"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip  &>>$LOG_FILE_NAME
VALIDATE $? "Unzipping backend code"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copying service file"

dnf install mysql &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql"

mysql -h mysql.pavancloud5.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Copying Backend file to DB"
