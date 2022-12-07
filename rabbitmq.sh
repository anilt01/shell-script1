source common.sh
LOG_FILE=/tmp/rabbitmq

echo "Download erlang dependencies for rabbitmq"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>$LOG_FILE
StatusCheck $?

echo "Install erlang"
yum install erlang -y &>>$LOG_FILE
StatusCheck $?

echo "Download rabbitmq repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$LOG_FILE
StatusCheck $?

echo "Install Rabbitmq"
yum install rabbitmq-server -y &>>$LOG_FILE
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