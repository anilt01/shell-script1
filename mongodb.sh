LOG_FILE=/tmp/mongodb
source=common.sh

echo Downloading Mongodb repos
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>LOG_FILE
StatusCheck $?

echo Installing Mongodb-org
yum install -y mongodb-org &>>LOG_FILE
StatusCheck $?

echo Enabling and starting mongod
systemctl enable mongod &>>LOG_FILE
systemctl start mongod &>>LOG_FILE
StatusCheck $?

echo updating ip address in
sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>LOG_FILE
StatusCheck $?

echo restarting mongodb
systemctl restart mongod &>>LOG_FILE
StatusCheck=$?
StatusCheck $?

echo Downloading Schema
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>LOG_FILE
StatusCheck $?

echo unzipping schema files in tmp folder
cd /tmp
unzip -o mongodb.zip &>>LOG_FILE
StatusCheck $?

echo Uploading catalogue and users schema
cd mongodb-main
mongo < catalogue.js &>>LOG_FILE
mongo < users.js &>>LOG_FILE
StatusCheck $?