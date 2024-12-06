#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
    then
    echo -e "\n$1"
  fi

  echo -e "\n~~~~~ MY SALON ~~~~~"
  echo How may I help you?
  echo -e "\nSelect a service from the list below:" 

  # get available services
   SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
   # if no services available
   if [[ -z $SERVICES ]]
  then
  #return to main menu
  MAIN_MENU "\nSorry that service is not available"
  else
  #display services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME 
  do 
  echo "$SERVICE_ID) $SERVICE_NAME" 
  done 

  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_NAME ]] 
    then 
    MAIN_MENU "\nInvalid service selection. Please choose a valid service." 
    else
    echo -e "\nEnter phone number:"  
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
      then
      echo -e "\nEnter customer name:" 
      read CUSTOMER_NAME 
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

    echo -e "\nEnter appointment time (HH:MM):" 
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')") 
    if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]] 
      then 
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." 
      else 
      echo -e "\nError booking appointment. Please try again." 
    fi
  fi
fi
}

MAIN_MENU