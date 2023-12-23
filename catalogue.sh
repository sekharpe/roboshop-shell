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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "the nodejs module old version disabled"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "the nodejs module new version enabled"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "the nodejs installation"

id roboshop
if [ $? -ne 0]
then
    useradd roboshop
    VALIDATE $? "the user roboshop created"
else
    echo -e " $Y SKIPPING $N since roboshop user already exist"
fi


mkdir -p /app
VALIDATE $? "the application app directory created"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Downloaded code to the application app directory"

cd /app 
npm install &>> $LOGFILE
VALIDATE $? "installing the npm dependencies"

unzip -o /tmp/catalogue.zip
VALIDATE $? "unzip the code in to the /app directory"

cp /root/roboshop-shell/catalogue.service /etc/systemd/system/
VALIDATE $? "catalogue service is created in /etc/systemd/system"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "catalogue service is loaded"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "catalogue service is enabled now"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "catalogue service is started now"

cp /root/roboshop-shell//mongo.repo /etc/yum.repos.d/ &>> $LOGFILE
VALIDATE $? "mongo.repo added to /etc/yum.repos"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "mongodb client installation to push content to db"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "loading the data to the DB"






