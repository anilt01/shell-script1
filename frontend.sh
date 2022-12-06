LOG_FILE=/tmp/frontend
echo Installing Nginx
yum install nginx -y &>>$LOG_FILE
StatusCheck=$?
if [ $? = 0 ]; then
  echo status = success
else
  echo status = failure
  exit 1
fi

echo starting and enabling nginx
systemctl enable nginx &>> $LOG_FILE
systemctl start nginx &>>$LOG_FILE
StatusCheck=$?
if [ $? = 0 ]; then
  echo status = success
else
  echo status = failure
  exit 1
fi

echo downloading repo file
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
StatusCheck=$?
if [ $? = 0 ]; then
  echo status =success
else
  echo status=failure
  exit 1
fi
echo clearup all the content
cd /usr/share/nginx/html &>>$LOG_FILE
rm -rf * &>> $LOG_FILE
StatusCheck=$?
if [ $? = 0 ]; then
  echo status =success
else
  echo status=failure
  exit 1
fi

echo unzipping the files
unzip /tmp/frontend.zip &>>$LOG_FILE
mv frontend-main/static/* . &>>$LOG_FILE
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
StatusCheck=$?
if [ $? = 0 ]; then
  echo status =success
else
  echo status=failure
  exit 1
fi

echo restarting nginx
systemctl restart nginx &>>$LOG_FILE
StatusCheck=$?
if [ $? = 0 ]; then
  echo status =success
else
  echo status=failure
  exit 1
fi

