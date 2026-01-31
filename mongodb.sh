#!/bin/bsh

ID=$(id -u)
mkdir -p shell-script
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"



if [ $ID -ne 0 ]; then
    echo "Please run the script with sudo user" &>>$LOG_FILE
    exit 1
else
    echo "Script is executed with sudo user hence installing the package"
fi

VALIDATION(){
    if [ $1 -ne 0 ]; then
        echo "$2 .. FAILED" &>>$LOG_FILE
        exit 1
    else
        echo "$2 ..SUCCESS" &>>$LOG_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATION $? "Config mogodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATION $? "mogodb instalation"

systemctl enable mongod &>>$LOG_FILE
VALIDATION $? "enebled mongod"

systemctl start mongod &>>$LOG_FILE
VALIDATION $? "mongod started"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATION $? "Configrastion done"

systemctl restart mongod &>>$LOG_FILE
VALIDATION $? "mongod restart"