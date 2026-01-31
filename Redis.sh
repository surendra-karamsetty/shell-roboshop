#!/bin/bash

ID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"

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

dnf module disable redis -y &>>$LOG_FILE
VALIDATION $? "disable redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATION $? "enable redis:7"

dnf install redis -y &>>$LOG_FILE
VALIDATION $? "install redis:7"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATION $? "Update listen address"

sed -i '/protected-mode/ s/yes/no/g' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATION $? "Update protected-mode"

systemctl enable redis &>>$LOG_FILE
VALIDATION $? "enable redis"

systemctl start redis &>>$LOG_FILE
VALIDATION $? "start redis"

