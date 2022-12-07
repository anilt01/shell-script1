source common.sh
LOG_FILE=/tmp/rabbitmq

echo Download rabbitmq repos
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOG_FILE
StatusCheck $?

echo Install erlang and Rabbitmq
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
StatusCheck $?

yum install erlang -y
StatusCheck $?

yum install rabbitmq-server -y
StatusCheck $?

echo "enable and start rabbitmq"
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
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