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

DEFAULT_PASSWORD=$( grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}') &>>LOG_FILE

# As we need to use the secure installation manually we are using different command to login mysql
echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${ROBOSHOP_MYSQL_PASSWORD}');
FLUSH PRIVILEGES;" >/tmp/root-pass.sql &>>LOG_FILE


echo change mysql root password
echo "show databases;" |mysql -uroot -p${ROBOSHOP_DEFAULT_PASSWORD}
if [ $? -ne 0 ]; then
 mysql -uroot --connect-expired-password -p"${DEFAULT_PASSWORD}" </tmp/root-pass.sql
 StatusCheck $?
fi

echo "show plugins" | mysql -uroot -p'{$ROBOSHOP_DEFAULT_PASSWORD}' | grep validate_password &>>LOG_FILE
if [ $? -eq 0 ] then;
 echo uninstall passowrd validation plugins
 echo "uninstall plugin validate_password;" | mysql -uroot -p'{$ROBOSHOP_DEFAULT_PASSWORD}' &>>LOG_FILE
 StatusCheck $?
fi

echo Download Schema files
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>LOG_FILE
StatusCheck $?

echo unzip schema files
cd /tmp
unzip mysql.zip
StatusCheck $?

echo load schema files
cd mysql-main
mysql -u root -pRoboShop@1 <shipping.sql
StatusCheck $?
