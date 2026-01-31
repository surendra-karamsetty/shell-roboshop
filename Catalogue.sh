#!/bin/bash

ID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_PATH="/home/ec2-user/shell-roboshop"
MONGODB_HOST=mongodb.venkata.online

mkdir -p $LOG_FOLDER

if [ $ID -ne 0 ]; then
    echo "Please run the script with sudo user"
    exit 1
else
    echo "Script executed with sudo user hence installing the package"
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
VALIDATION $? "nodejs instalation"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATION $? "User craeted"
else
    echo "roboshop user is alreday exist so ..SKIPPING"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATION $? "Directory created"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATION $? "Downloading the code"

cd /app &>>$LOG_FILE
VALIDATION $? "MOving to app directory"

rm -rf /app/*
VALIDATION $? "Clean up"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATION $? "Code unzip"

cd /app &>>$LOG_FILE
VALIDATION $? "MOving to app directory"

npm install &>>$LOG_FILE
VALIDATION $? "Installed dependencies"

cp $SCRIPT_PATH/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATION $? "Service script copied"

systemctl daemon-reload &>>$LOG_FILE
VALIDATION $? "Installed dependencies"

systemctl enable catalogue &>>$LOG_FILE
VALIDATION $? "enable catalogue service"

systemctl start catalogue &>>$LOG_FILE
VALIDATION $? "catalogue service started"

cp $SCRIPT_PATH/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATION $? "coppied mongo.repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATION $? "mongodb-mongosh installed"

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")') &>>$LOG_FILE

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATION $? "Loading products"
else
    echo "Products already exits so ..SKIPPING"
fi

systemctl restart catalogue &>>$LOG_FILE
VALIDATE $? "Restarting catalogue"





