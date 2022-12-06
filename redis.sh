LOG_FILE=/tmp/redis
source=common.sh

echo install redis repo files
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
StatusCheck $?

echo enabke redis module
dnf module enable redis:remi-6.2 -y
StatusCheck $?

echo install Redis
yum install redis -y
StatusCheck $?

echo Update Listen address
sed -i -e 's/127.0.0.1/0.0.0.0' /etc/redis.conf /etc/redis/redis.conf
StatusCheck $?

echo start and enable redis service
systemctl enable redis
systemctl start redis
StatusCheck $?