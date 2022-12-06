ID=$(id -u)
if [ $ID -ne 0 ]; then
  echo Please use sudo access or be a ROOT user to run the script
  exit 1
fi

StatusCheck () {
  if [ $? -eq 0 ]; then
    echo status = "\e[32mSUCCESS\e[0m"
  else
    echo status = "\e[31mFAILURE\e[0m"
    exit 1
  fi
}