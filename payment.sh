#!/bin/bash

ID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_PATH="/home/ec2-user/shell-roboshop"

mkdir -p $LOG_FOLDER


if [ $ID -ne 0 ]; then
    echo "Please execute the script with the sudo user"
    exit 1
else
    echo "Script is executed with sudo so installing the package"
fi

VALIDATION(){
    if [ $1 -ne 0 ]; then
        echo "$2 ..FAILED"
        exit 1
    else
        echo "$2 ..SUCCESS"
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATION $? "Installed python3 gcc python3-devel"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    echo "User created"
else
    echo "User is alreday exits so skipping"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATION $? "app directory created"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATION $? "Downloading the code"

cd /app &>>$LOG_FILE
VALIDATION $? "Moving to app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATION $? "Clean app directory"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATION $? "UN zip the code"

cd /app &>>$LOG_FILE
VALIDATION $? "Moving to app directory" 

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATION $? "pip3 install" 

cp /$SCRIPT_PATH/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATION $? "copy the payment.service" 

systemctl daemon-reload &>>$LOG_FILE
VALIDATION $? "daemon-reload" 

systemctl enable payment &>>$LOG_FILE
VALIDATION $? "enable payment" 

systemctl start payment &>>$LOG_FILE
VALIDATION $? "start payment" 


