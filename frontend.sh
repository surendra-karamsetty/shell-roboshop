#!/bin/bsh

ID=$(id -u)
SCRIPT_PATH="/home/ec2-user/shell-roboshop"

if [ $ID -ne 0 ]; then
    echo "Please execute the script with sudo user"
    exit 1
else
    echo "Script is execute with the sudo user hence installing the package"
fi

VALIDATION(){
    if [ $1 -ne 0 ]; then
        echo "$2 ..FAILED"
        exit 1
    else
        echo "$2 ..SUCCESS"
    fi
}


dnf module disable nginx -y
VALIDATION $? "disable nginx"

dnf module enable nginx:1.24 -y
VALIDATION $? "module enable nginx:1.24"

dnf install nginx -y
VALIDATION $? "nginx Instalation"

systemctl enable nginx 
VALIDATION $? "enable nginx"

systemctl start nginx 
VALIDATION $? "nginx Started"

rm -rf /usr/share/nginx/html/* 
VALIDATION $? "Remove the default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATION $? "Dowload the code"

cd /usr/share/nginx/html 
VALIDATION $? "Going to html path"

unzip /tmp/frontend.zip
VALIDATION $? "Unzip the code"

cp /$SCRIPT_PATH/nginx.conf /etc/nginx/nginx.conf
VALIDATION $? "nginx.conf file copied"

systemctl restart nginx 
VALIDATION $? "Restarted nginx server"

