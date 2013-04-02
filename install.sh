#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )"; pwd )"

read -e -p "GitHub Username: " USERNAME

exec 3>&1
eval "$( curl -s -X POST 'https://api.github.com/authorizations' -u "$USERNAME" -d @auth.json 2> >( ./curl-prompt.py >&3 ) | ./auth.py )"
exec 3>&-

git config --global AutoHub.id "$AUTOHUB_ID"
git config --global AutoHub.token "$AUTOHUB_TOKEN"
git config --global alias.gist '!'"$DIR"/gist.sh
