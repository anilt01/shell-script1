LOG_FILE=/tmp/mysql
source common.sh
echo Download mysqlrepo file
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>LOG_FILE
StatusCheck $?

echo disable previous/installed version of mysql in the server
dnf module disable mysql -y &>>LOG_FILE
StatusCheck $?

echo Install mysql server 5.7 version
yum install mysql-community-server -y &>>LOG_FILE
StatusCheck $?

echo enable and start mysql server
systemctl enable mysqld &>>LOG_FILE
systemctl start mysqld &>>LOG_FILE
StatusCheck $?

DEFAULT_PASSWORD=$( grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')

# As we need to use the secure installation manually we are using different command to login mysql
echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${ROBOSHOP_MYSQL_PASSWORD}');
FLUSH PRIVILEGES;" >/tmp/root-pass.sql

echo change mysql root password
mysql -uroot -p"$DEFAULT_PASSWORD" </tmp/root-pass.sql



