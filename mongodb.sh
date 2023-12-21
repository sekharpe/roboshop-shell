#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
ID=$(id -u)

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
    else
    echo -e "$2 is $G SUCCESS $N"
    fi
}

cp mongo.repo /etc/yum.repos.d
VALIDATE $? "the mongo.repo has been added to the /etc/yum.repos folder"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "the mongodb installation"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "the mongodb is enabled now"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "the mongodb is started "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "the mongodb port 0.0.0.0 has been changed "

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "the mongod is restarted"

