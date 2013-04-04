#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )"; pwd )"

read -e -p "GitHub Username: " USERNAME

exec 3>&1
eval "$( curl -s -X POST 'https://api.github.com/authorizations' -u "$USERNAME" -d @"$DIR"/payload/auth.json 2> >( ./bin/curl-prompt.py >&3 ) | ./bin/auth.py )"
exec 3>&-

git config --global AutoHub.id "$AUTOHUB_ID"
git config --global AutoHub.token "$AUTOHUB_TOKEN"
git config --global alias.gist '!'"$DIR"/gist.sh
git config --global alias.hubbit '!'"$DIR"/hubbit.sh
