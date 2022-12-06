LOG_FILE=/tmp/redis
source common.sh

echo install redis repo files
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>LOG_FILE
StatusCheck $?

echo enable redis module
dnf module enable redis:remi-6.2 -y &>>LOG_FILE
StatusCheck $?

echo install Redis
yum install redis -y &>>LOG_FILE
StatusCheck $?

echo Update Listen address
sed -i -e 's/127.0.0.1/0.0.0.0' /etc/redis.conf /etc/redis/redis.conf &>>LOG_FILE
StatusCheck $?

echo start and enable redis service
systemctl enable redis &>>LOG_FILE
systemctl start redis &>>LOG_FILE
StatusCheck $?