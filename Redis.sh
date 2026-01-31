#!/bin/bash

ID=$(id -u)


if [ $id -ne 0 ]; then
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

dnf module disable redis -y
VALIDATION $? "disable redis"

dnf module enable redis:7 -y
VALIDATION $? "enable redis:7"

dnf install redis -y 
VALIDATION $? "install redis:7"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATION $? "Update listen address"

sed -i '/protected-mode/ s/yes/no/g' /etc/redis/redis.conf
VALIDATION $? "Update protected-mode"

systemctl enable redis 
VALIDATION $? "enable redis"

systemctl start redis 
VALIDATION $? "start redis"

