#!/bin/bash

ID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
mkdir -p $LOG_FOLDER
SCRIPT_PATH="/home/ec2-user/shell-roboshop"


if [ $ID -ne 0 ]; then
    echo "Please run the scrip with sudo user"
    exit 1
else
    echo "Script is executed with sudo user hence executing the script"
fi

VALIDATION(){
    if [ $1 -ne 0 ]; then
        echo "$2 ..FAILED"
        exit 1
    else
        echo "$2 ..SUCCESS"
    fi
}

dnf module disable nodejs -y &>>LOG_FILE
VALIDATION $? "disable nodejs"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATION $? "enable nodejs:20"

dnf install nodejs -y &>>LOG_FILE
VALIDATION $? "Installed nodejs"

id roboshop
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    echo "User created"
else
    echo "User is already created so skipping this step"
fi

mkdir -p /app &>>LOG_FILE
VALIDATION $? "app directory created"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>LOG_FILE
VALIDATION $? "Downloaded the code"

cd /app &>>LOG_FILE
VALIDATION $? "Moved to app folder"

rm -rf /app/* &>>LOG_FILE
VALIDATION $? "Clean up done for app folder"

unzip /tmp/cart.zip &>>LOG_FILE
VALIDATION $? "Unzip the code"

cd /app &>>LOG_FILE
VALIDATION $? "Moved to app folder"

npm install &>>LOG_FILE
VALIDATION $? "dependencies downloaded"

cp /$SCRIPT_PATH/cart.service /etc/systemd/system/cart.service
VALIDATION $? "cart services copied"

systemctl daemon-reload
VALIDATION $? "daemon-reload"

systemctl enable cart 
VALIDATION $? "cart enable"

systemctl start cart
VALIDATION $? "cart start"






