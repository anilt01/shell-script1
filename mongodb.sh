LOG_FILE=/tmp/mongodb
source common.sh

echo Downloading repos
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo
StatusCheck $?

echo Installing Mongodb
yum install -y mongodb-org
StatusCheck $?

echo Updating Listen Adress
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
StatusCheck $?

echo enabling Mongodb
systemctl enable mongod
StatusCheck $?

echo Restarting Mongodb
systemctl restart mongod
StatusCheck $?

echo clear previous files
cd /home/roboshop/tmp
rm -rf mongodb*
StatusCheck $?

echo "Download Schema files"
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip"
StatusCheck $?


cd /tmp
echo Unzipping the files
unzip mongodb.zip
StatusCheck $?

echo Loading catalogue and users schema
cd mongodb-main
mongo < catalogue.js
mongo < users.js
StatusCheck $?