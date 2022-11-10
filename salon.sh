#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Kevin's Nails ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to Kevin's Nails. What would you like to do today?\n"

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo -e "$SERVICE_ID) $SERVICE"
  done

  # echo -e "\n1. Hair\n2. Makeup\n3. Nails"
  read SERVICE_ID_SELECTED

  #exit app
 

    # if input isn't a number
    while [[ ! $SERVICE_ID_SELECTED =~ ^[0-3]+$ ]]
    do
      # show list again until correct choice is made
        echo -e "\nI can't find that service. How else can I help you?\n"
        echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
        do
          echo -e "$SERVICE_ID) $SERVICE"
        done
        read SERVICE_ID_SELECTED
    done
    # get customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_PHONE_CHECK=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_PHONE_CHECK ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        CUSTOMER_NAME_CHECK=$($PSQL "SELECT name FROM customers WHERE name='$CUSTOMER_NAME'")

        if [[ -z $CUSTOMER_NAME_CHECK ]]
        then
          CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

          echo -e "\nWhat time would you like to schedule your appt., $CUSTOMER_NAME_FORMATTED?"
          read SERVICE_TIME
          
          # insert customer name and phone
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME_FORMATTED', '$CUSTOMER_PHONE')")

          # get customer_id
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME_FORMATTED'")
          
          # insert appointment 
          INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', $SERVICE_ID_SELECTED)")

          SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          SERVICE_INFO_FORMATTED=$(echo $SERVICE_INFO | sed -r 's/^ *| *$//g')

          # return to main menu
          MAIN_MENU "I've put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
        fi
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

        echo -e "Welcome back $CUSTOMER_NAME_FORMATTED! I'm happy to see you again!"

        echo -e "\nWhat time would you like to schedule your service, $CUSTOMER_NAME_FORMATTED?"
        read SERVICE_TIME

        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME_FORMATTED'")

        # insert appointment 
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', $SERVICE_ID_SELECTED)")

        SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        SERVICE_INFO_FORMATTED=$(echo $SERVICE_INFO | sed -r 's/^ *| *$//g')

        # return to main menu
        MAIN_MENU "I've put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
      fi
}

EXIT() {
  echo -e "\nThanks for stopping by. See you again soon! :)"
}

MAIN_MENU


