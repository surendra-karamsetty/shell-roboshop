#!/bin/bash

ID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_PATH="/home/ec2-user/shell-roboshop"

mkdir -p $LOG_FOLDER

if [ $ID -ne 0 ]; then
    echo "Please run the script with the sudo user"
    exit 1
else
    echo "Script is executed with sudo user hence installing the package"
fi

VALIDATION(){
    if [ $1 -ne 0 ]; then
        echo "$2 ..FAILED"
        exit 1
    else
        echo "$2 ..SUCCESS"
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATION $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATION $? "enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATION $? "install nodejs"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATION $? "USer created"
else
    echo "roboshop user is alreday exist so ..SKIPPING"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATION $? "app directory created"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATION $? "Download the code"

cd /app &>>$LOG_FILE
VALIDATION $? "GO to app directory"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATION $? "unzip the code"

cd /app &>>$LOG_FILE
VALIDATION $? "GO to app directory"

npm install &>>$LOG_FILE
VALIDATION $? "npm instalation"

cp $SCRIPT_PATH/user.service /etc/systemd/system/user.service &>>$LOG_FILE

systemctl daemon-reload &>>$LOG_FILE
VALIDATION $? "daemon-reload"

systemctl enable user &>>$LOG_FILE
VALIDATION $? "enable user"

systemctl start user &>>$LOG_FILE
VALIDATION $? "start user"


