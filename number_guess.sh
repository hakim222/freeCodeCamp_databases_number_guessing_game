#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$((1 + RANDOM % 1000))

echo Enter your username:

read ENTERED_USERNAME
RESULT1=$($PSQL "select username, games_played, best_game from scores where username='$ENTERED_USERNAME'")

if [[ -z $RESULT1 ]]
then
  ADD_NEW_USER=$($PSQL "insert into scores(username,games_played,best_game) values('$ENTERED_USERNAME',0,0)")
  echo -e "Welcome, $ENTERED_USERNAME! It looks like this is your first time here."
  USERNAME=$ENTERED_USERNAME
  GAMES_PLAYED=0
  BEST_GAME=0
else
  IFS="|" read USERNAME GAMES_PLAYED BEST_GAME <<< "$RESULT1"
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
TRY_NUM=0
echo -e "Guess the secret number between 1 and 1000:"

GUESS_LOOP(){
  if [[ $1 ]]
    then echo -e $1
  fi
  read GUESS
  if ! [[ "$GUESS" =~ ^[0-9]+(\.[0-9]+)?$ ]]
  then 
    GUESS_LOOP "That is not an integer, guess again:"
  else
    TRY_NUM=$((TRY_NUM + 1))
    if [[ "$RANDOM_NUMBER" == "$GUESS" ]]
    then
      echo -e "You guessed it in $TRY_NUM tries. The secret number was $RANDOM_NUMBER. Nice job!"
      if (( BEST_GAME==0 ))
      then 
        ADD_NEW_SCORE=$($PSQL "update scores set games_played=games_played+1, best_game=$TRY_NUM where username='$USERNAME'")
      else
        if (( BEST_GAME > TRY_NUM ))
        then
          ADD_NEW_SCORE=$($PSQL "update scores set games_played=games_played+1, best_game=$TRY_NUM where username='$USERNAME'")
        else
          ADD_NEW_SCORE=$($PSQL "update scores set games_played=games_played+1 where username='$USERNAME'")
        fi
      fi
    else
      if (( GUESS > RANDOM_NUMBER ))
      then
        GUESS_LOOP "It's lower than that, guess again:"
      else
        GUESS_LOOP "It's higher than that, guess again:"
      fi
    fi
  fi
}
GUESS_LOOP