#!/bin/bash
. ~/.i3/gmailaccount

COUNT=`curl -su $GMAIL_USER:$GMAIL_PASS https://mail.google.com/mail/feed/atom || echo "<fullcount>-</fullcount>"`
COUNT=`echo "$COUNT" | grep -oPm1 "(?<=<fullcount>)[^<]+" `
echo $COUNT
