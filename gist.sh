#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )"; pwd )"

. "$DIR"/bin/parse-args d: description p public h help -- "$@"

DESCRIPTION=""
PUBLIC="false"

while getopts "$GETOPTS_ARGS" arg
do
	case "$arg" in
	d)
		DESCRIPTION="$OPTARG"
	;;
	p)
		PUBLIC="true"
	;;
	h)
		echo "git gist [--description DESCRIPTION] [--PUBLIC]" >&2
		exit
	;;
	esac
done

GIST_URL=""

IS_GIT=0

SHOW=$( git remote -v show 2> /dev/null )

# No git Repo yet.  Make one.
if [ 0 -ne $? ]
then
	git init
else
	IS_GIT=1
	git status | grep 'nothing to commit (working directory clean)' &> /dev/null
	if [ 0 -ne $? ]
	then
		echo "Please start with a clean working directory!" >&2
		exit 1
	fi
fi

echo "$SHOW" | egrep '^origin\s+git@gist.github.com:' &> /dev/null
if [ 0 -eq $? ]
then
	echo "Already a Gist :)" >&2
	exit
fi

DESCRIPTION=$( echo -n "$DESCRIPTION" | python -c 'import json; import sys; print json.dumps( sys.stdin.read() )' )

if [ "public" == "$PUBLIC" ]
then
	PUBLIC="true"
else
	PUBLIC="false"
fi

JSON=$( cat "$DIR/payload/gists.json" )
JSON=${JSON/__DESCRIPTION__/$DESCRIPTION}
JSON=${JSON/__PUBLIC__/$PUBLIC}

eval "$( echo "$JSON" | curl -s -H "Authorization: BEARER $(git config --global AutoHub.token)" https://api.github.com/gists -X POST -d @- | "$DIR/"bin/gists.py )"
if [ 0 -ne $? -o -z "$GIST_URL" ]
then
	echo "Gist creation failed :(" >&2
	exit 1
fi

git remote add origin "$GIST_URL"
git pull origin master
git rm autohub.init > /dev/null
if [ 1 -eq $IS_GIT ]
then
	git reset --hard HEAD~1
else
	git add '*'
	git commit --amend -m "init"
fi
git push origin --force

GIST_URL=${GIST_URL/#"git@gist.github.com:"/"https://gist.github.com/"}
GIST_URL=${GIST_URL%".git"}

echo
echo "Created Gist at $GIST_URL"
