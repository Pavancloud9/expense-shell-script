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

dnf list installed mysql-server
if  [ $? -ne 0 ]
    then

dnf install mysql-server -y
    VALIDATE $? "Installing Mysql-server"

else
    echo "MYSQL-SERVER....ALREADY INSTALLED"
fi

systemctl enable mysqld
VALIDATE $? "Enabling mysql-server"

systemctl start mysqld
VALIDATE $? "Starting mysql-server"

mysql -h 172.31.20.178 -uroot -pExpenseApp@1 -e 'show databases';
if [ $? -ne 0 ]
    then
mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "setting root password" 
else
    echo "MYSQL ROOT PASSWORD SETUP HAS BEEN DONE...SKIPPING"
fi



