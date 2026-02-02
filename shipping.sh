#!/bin/bash

ID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_PATH="/var/log/shell-script"
MYSQL_SERVER="mysql.venkata.online"

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

dnf install maven -y &>>LOG_FILE
VALIDATION $? "Installed maven"


id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    echo "User got created"
else
    echo "Alreday user is exist so skipping this step"
fi

mkdir -p /app &>>LOG_FILE
VALIDATION $? "app directory created"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>LOG_FILE
VALIDATION $? "Downloading the code"

cd /app &>>LOG_FILE
VALIDATION $? "Moving to app directory"

rm -rf /app/* &>>LOG_FILE
VALIDATION $? "Clean up app directory"

unzip /tmp/shipping.zip &>>LOG_FILE
VALIDATION $? "Un zip the code"

cd /app &>>LOG_FILE
VALIDATION $? "Moving to app directory"

mvn clean package &>>LOG_FILE
VALIDATION $? "MVN Clean up the package"

mv target/shipping-1.0.jar shipping.jar &>>LOG_FILE
VALIDATION $? "Jar file is updated"

cp /$SCRIPT_PATH/shipping.service /etc/systemd/system/shipping.service &>>LOG_FILE
VALIDATION $? "Services script moved"

systemctl daemon-reload &>>LOG_FILE
VALIDATION $? "daemon-reload"


dnf install mysql -y &>>LOG_FILE
VALIDATION $? "mysql installed"

mysql -h $MYSQL_SERVER -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

    mysql -h $MYSQL_SERVER -uroot -pRoboShop@1 < /app/db/schema.sql &>>LOG_FILE
    mysql -h $MYSQL_SERVER -uroot -pRoboShop@1 < /app/db/app-user.sql &>>LOG_FILE
    mysql -h $MYSQL_SERVER -uroot -pRoboShop@1 < /app/db/master-data.sql &>>LOG_FILE
    VALIDATE $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

systemctl enable shipping &>>LOG_FILE
VALIDATION $? "shipping enabled"

systemctl start shipping &>>LOG_FILE
VALIDATION $? "shipping started"

systemctl restart shipping &>>LOG_FILE
VALIDATION $? "restart shipping"

