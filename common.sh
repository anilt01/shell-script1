ID=$(id -u)
if [ $ID -ne 0 ]; then
  echo Please use sudo access or be a ROOT user to run the script
  exit 1
fi

StatusCheck () {
  if [ $? -eq 0 ]; then
    echo -e status = "\e[32mSUCCESS\e[0m"
  else
    echo -e status = "\e[31mFAILURE\e[0m"
    exit 1
  fi
}

NODEJS () {
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

  echo Download ${COMPONENT} application code
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>LOG_FILE
  StatusCheck $?

  echo unzip the files in tmp folder
  cd /home/roboshop
  rm -rf ${COMPONENT}
  unzip /tmp/${COMPONENT}.zip &>>LOG_FILE
  mv ${COMPONENT}-main ${COMPONENT} &>>LOG_FILE
  StatusCheck $?

  echo Install NodeJs depedencies
  cd /home/roboshop/${COMPONENT} &>>LOG_FILE
  npm install &>>LOG_FILE
  StatusCheck $?

  echo Setup systemD service file
  sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.intenal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/g' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/g' /home/roboshop/${COMPONENT}/systemd.service
  StatusCheck $?

  echo setup ${COMPONENT} service
  cd /home/roboshop
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>LOG_FILE
  StatusCheck $?

  echo reload ${COMPONENT} service
  systemctl daemon-reload &>>LOG_FILE
  StatusCheck $?

  echo start and enable ${COMPONENT} service
  systemctl start ${COMPONENT} &>>LOG_FILE
  systemctl enable ${COMPONENT} &>>LOG_FILE
  StatusCheck $?
}