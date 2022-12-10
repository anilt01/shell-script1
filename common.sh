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



APP_PREREQ() {

  echo add an application user
  id roboshop &>>LOG_FILE
  if [ $? -ne 0 ]; then
  useradd roboshop &>>LOG_FILE
  StatusCheck $?
  fi


  echo Download ${COMPONENT} application code
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>LOG_FILE
  StatusCheck $?

  echo unzip the files in tmp folder
  cd /home/roboshop
  rm -rf ${COMPONENT}
  unzip /tmp/${COMPONENT}.zip &>>LOG_FILE
  mv ${COMPONENT}-main ${COMPONENT} &>>LOG_FILE
  StatusCheck $?
}


SYSTEMD_SETUP() {
  echo Setup systemD service file
  sed -i  -e 's/RABBITMQ-IP/rabbitmq.roboshop.internal/g' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/g' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/g' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/g' -e 's/CARTENDPOINT/cart.roboshop.internal/g' -e 's/DBHOST/mysql.roboshop.internal/g' -e 's/CARTHOST/cart.roboshop.internal/g' -e 's/USERHOST/user.roboshop.internal/g' -e 's/AMQPHOST/rabbitmq.roboshop.internal/g' /home/roboshop/${COMPONENT}/systemd.service
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


NODEJS() {
  echo download and Install NodeJs repos
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>LOG_FILE
  yum install nodejs -y &>>LOG_FILE
  StatusCheck $?

  APP_PREREQ

  echo Install NodeJs depedencies
  cd /home/roboshop/${COMPONENT} &>>LOG_FILE
  npm install &>>LOG_FILE
  StatusCheck $?

  SYSTEMD_SETUP
}

MAVEN() {
  #maven installs java
  echo "Install Maven"
  yum install maven -y &>>LOG_FILE
  StatusCheck $?

  APP_PREREQ

  cd /home/roboshop/${COMPONENT}
  echo " clean the package"
  mvn clean package &>>LOG_FILE
  StatusCheck $?
  echo "move shipping jar file"
  mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar &>>LOG_FILE
  StatusCheck $?

  SYSTEMD_SETUP
}

PYTHON() {
  echo "Install python"
  yum install python36 gcc python3-devel -y &>>$LOG_FILE
  StatusCheck $?

  APP_PREREQ

  echo " Install python dependencies"
  cd /home/roboshop/${COMPONENT}
  pip3 install -r requirements.txt &>>$LOG_FILE
  StatusCheck $?

  uid=$(id -u roboshop)
  gid=$(id -g roboshop)

  sed -i -e "/uid/ c uid = ${uid}" -e "/gid/ c gid = ${gid}" /home/roboshop/${COMPONENT}/${COMPONENT}.ini &>>$LOG_FILE

  SYSTEMD_SETUP
}

GOLANG() {

  echo "Install Golang package"
  yum install golang -y &>>$LOG_FILE
  StatusCheck $?

  APP_PREREQ

  cd /home/roboshop/${COMPONENT}

  echo "Track code dependencies by creating a go.mod file"
  go mod init ${COMPONENT} &>>$LOG_FILE
  StatusCheck $?

  echo "Install dependencies"
  go get &>>$LOG_FILE
  StatusCheck $?

  echo " build the command"
  go build &>>$LOG_FILE
  StatusCheck $?

  SYSTEMD_SETUP
}