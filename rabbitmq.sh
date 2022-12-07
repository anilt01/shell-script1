source common.sh
LOG_FILE=/tmp/rabbitmq

echo Download rabbitmq repos
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$LOG_FILE
StatusCheck $?

echo Install erlang and Rabbitmq
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm -y &>>$LOG_FILE
StatusCheck $?

echo "enable and start rabbitmq"
systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
StatusCheck $?

rabbitmqctl list_users | grep roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
 rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
 StatusCheck $?
fi

echo " Edit tags for roboshop"
rabbitmqctl set_user_tags roboshop administrator &>>$LOG_FILE
StatusCheck $?

echo " Set permission for roboshop user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
StatusCheck $?