#!/bin/bash

ID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
mkdir -p $LOG_FOLDER

if [ $ID -ne 0 ]; then
    echo "Please executed the scrip with sudo user"
    exit 1
else
    echo "Script is executed with sudo user henc installing the package"
fi

VALIDATION(){
    if [ $1 -ne 0 ]; then
        echo "$2 ..FAILED"
    else
        echo "$2 ..SUCCESS"
    fi
}

dnf install mysql-server -y &>>LOG_FILE
VALIDATION $? "Installed mysql-server"

systemctl enable mysqld &>>LOG_FILE
VALIDATION $? "enable mysqld"

systemctl start mysqld &>>LOG_FILE
VALIDATION $? "start mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>>LOG_FILE
VALIDATION $? "Password set"

