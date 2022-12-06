LOG_FILE=/tmp/mysql
source common.sh
echo Download mysqlrepo file
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>LOG_FILE
StatusCheck $?

echo disable previous/installed bersion of mysql in the server
dnf module disable mysql &>>LOG_FILE
StatusCheck $?

echo Install mysql server 5.7 version
yum install mysql-community-server -y &>>LOG_FILE
StatusCheck $?

echo enable and start mysql server
systemctl enable mysqld &>>LOG_FILE
systemctl start mysqld &>>LOG_FILE
StatusCheck $?

