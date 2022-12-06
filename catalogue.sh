LOG_FILE=/tmp/catalogue
source common.sh

echo download and Install NodeJs repos
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>LOG_FILE
yum install nodejs -y &>>LOG_FILE
StatusCheck $?

echo add an application user
id roboshop &>>LOG_FILE
if [ $? -ne 0 ]; then
useradd roboshop &>>LOG_FILE
fi
StatusCheck $?

echo Download catalogue application code
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>LOG_FILE
StatusCheck $?

echo unzip the files in tmp folder
cd /home/roboshop
unzip -o /tmp/catalogue.zip
mv -o catalogue-main catalogue
StatusCheck $?

echo Install NodeJs depedencies
cd /home/roboshop/catalogue &>>LOG_FILE
npm install &>>LOG_FILE
StatusCheck $?

echo setup catalogue service
cd /home/roboshop
rm -rf catalogue
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>LOG_FILE
StatusCheck $?

echo reload catalogue service
systemctl daemon-reload &>>LOG_FILE
StatusCheck $?

echo start and enable catalogue service
systemctl start catalogue &>>LOG_FILE
systemctl enable catalogue &>>LOG_FILE
StatusCheck $?
