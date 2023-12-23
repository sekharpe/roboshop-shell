#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
ID=$(id -u)
MONGODB_HOST=mongodb.pghub.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
if [ $ID -ne 0 ]
then
echo -e "please switch to root user"
else
echo -e "you are the root user to run the sript"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2 is $R FAILED $N"
    exit 1
    else
    echo -e "$2 is $G SUCCESS $N"
    fi
}

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "install nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabled the nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting the service nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "rempving the original nginx template code"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "downloading the frontend code nginx"

cd /usr/share/nginx/html
VALIDATE $? "switching to /usr/share/nginx/html directory"

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping the code nginx html directory"

cp /root/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf 
VALIDATE $? "copied the roboshop config file"

systemctl restart nginx  &>> $LOGFILE
VALIDATE $? "nginx service restart complted"

