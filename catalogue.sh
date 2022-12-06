LOG_FILE=/tmp/catalogue
source=common.sh

echo download and Install NodeJs repos
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>LOG_FILE
yum install nodejs -y &>>LOG_FILE
StatusCheck $?

echo add an application user
useradd roboshop &>>LOG_FILE
StatusCheck $?

echo Download catalogue application code
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>LOG_FILE
StatusCheck $?

echo unzip the files in tmp folder
cd /home/roboshop
unzip /tmp/catalogue.zip &>>LOG_FILE
mv catalogue-main catalogue &>>LOG_FILE
StatusCheck $?

echo Install NodeJs depedencies
cd /home/roboshop/catalogue &>>LOG_FILE
npm install &>>LOG_FILE
StatusCheck $?

echo setup catalogue service
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>LOG_FILE
StatusCheck $?

echo reload catalogue service
systemctl daemon-reload &>>LOG_FILE
StatusCheck $?

echo start and enable catalogue service
systemctl start catalogue &>>LOG_FILE
systemctl enable catalogue &>>LOG_FILE
StatusCheck $?