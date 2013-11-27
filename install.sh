#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )"; pwd )"
USERNAME=$1
OTP=$2

if [ -z "$USERNAME" ]
then
	read -e -p "GitHub Username: " USERNAME
fi

exec 3>&1
if [ -z "$OTP" ]
then
	RESULT="$( curl -is -X POST 'https://api.github.com/authorizations' -u "$USERNAME" -d @"$DIR"/payload/auth.json 2> >( ./bin/curl-prompt.py >&3 ) | ./bin/auth.py )"
else
	RESULT="$( curl -is -X POST 'https://api.github.com/authorizations' -u "$USERNAME" -H "X-GitHub-OTP: $OTP" -d @"$DIR"/payload/auth.json 2> >( ./bin/curl-prompt.py >&3 ) | ./bin/auth.py )"
fi
exec 3>&-

if [ "OTP" = "$RESULT" ]
then
	read -e -p "GitHub Two-Factor Authentication Token: " TOKEN
	"$DIR"/install.sh "$USERNAME" "$TOKEN"
	exit
fi

eval "$RESULT"

git config --global AutoHub.id "$AUTOHUB_ID"
git config --global AutoHub.token "$AUTOHUB_TOKEN"
git config --global alias.gist '!'"$DIR"/gist.sh
git config --global alias.hubbit '!'"$DIR"/hubbit.sh
