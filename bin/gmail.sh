#!/bin/bash

# Script para ver la cantidad de correos de Gmail.
# Imprime la cantidad o "err" en caso de algún error
# -c -> Guarda resultado en ~/.gmail (para conky)
# 12 ene 2015

# Available system labels
# https://developers.google.com/gmail/android/com/google/android/gm/contentprovider/GmailContract.Labels.LabelCanonicalNames#constants
#
# Originally found at https://stackoverflow.com/questions/24959370/list-of-gmail-atom-available-labels/25515535#25515535

# Ruta a los password
. ~/.private/accounts

MAIL=`curl -u $MAIL_USER:"$MAIL_PASS" --silent https://mail.google.com/mail/feed/atom/%5Ei`
CON=`echo $MAIL | grep -c "<fullcount>"`
NUM=`echo $MAIL | xml_grep 'fullcount' --text_only`
#NUM=`echo $MAIL | grep -o "<entry>" | wc -l`
RES="err"

if [ $CON -ne 1 ]; then
  RES="err"
else
  RES="$NUM"
fi

if [ "$1" = "-c" ]; then
  echo "$RES" > ~/.gmail
else
  echo $RES
fi
