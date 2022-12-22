LOG_FILE=/tmp/mongodb
source common.sh

echo Downloading repos
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>$LOG_FILE
StatusCheck $?

echo Installing Mongodb
yum install -y mongodb-org &>>$LOG_FILE
StatusCheck $?

echo Updating Listen Adress
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$LOG_FILE
StatusCheck $?

echo enabling Mongodb
systemctl enable mongod &>>$LOG_FILE
StatusCheck $?

echo Restarting Mongodb
systemctl restart mongod &>>$LOG_FILE
StatusCheck $?

echo clear previous files
cd /tmp
rm -rf mongodb* &>>$LOG_FILE
StatusCheck $?

echo "Download Schema files"
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>$LOG_FILE
StatusCheck $?


cd /tmp
echo Unzipping the files
unzip mongodb.zip &>>$LOG_FILE
StatusCheck $?

echo Loading catalogue and users schema
cd mongodb-main
mongo < catalogue.js &>>$LOG_FILE
mongo < users.js &>>$LOG_FILE
StatusCheck $?