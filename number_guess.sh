#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=numberguessingdb --no-align --tuples-only -c"
#generate random number betn 1 - 1000
RANDOM_NUMBER=$((RANDOM % 1000 + 1))
echo 'Enter your username:'
read USERNAME
#if username not empty
if [[ ! -z $USERNAME ]]
then
  #check if username exists in db
  USERNAME_EXISTS_DB=$($PSQL "SELECT * FROM users WHERE user_name = '$USERNAME'")
  #if new user
  if [[ -z $USERNAME_EXISTS_DB ]]
  then
    #greet new user
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # add user to db
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(user_name) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name = '$USERNAME'")
  else
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name = '$USERNAME'")
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users FULL JOIN games USING(user_id) WHERE user_id = $USER_ID")
    BEST_GUESS=$($PSQL "SELECT MIN(guess_count) FROM users FULL JOIN games USING(user_id) WHERE user_id = $USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  fi
  #prompt user to guess a number
  echo -e "\nGuess the secret number between 1 and 1000:"
  GUESS_COUNT=1
  NUMBER_GUESS=
  while [[ $NUMBER_GUESS != $RANDOM_NUMBER ]]
  do
    read NUMBER_GUESS
    if [[ ! $NUMBER_GUESS =~ [0-9]+ ]]
    then
      #if not an integer
      echo "That is not an integer, guess again:"
    else
      if [[ $NUMBER_GUESS -gt $RANDOM_NUMBER ]]
        then
          echo "It's lower than that, guess again:"
          GUESS_COUNT=$((GUESS_COUNT + 1))
        elif [[ $NUMBER_GUESS -lt $RANDOM_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          GUESS_COUNT=$((GUESS_COUNT + 1))
        elif [[ $NUMBER_GUESS == $RANDOM_NUMBER ]]
        then
          INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guess_count) VALUES($USER_ID, $GUESS_COUNT)")
          echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER_GUESS. Nice job!"
      fi
    fi
  done
fi