#!/usr/bin/env bash

function helpquit {
	STATUS=0
	if [ $1 -ge 0 ]; then STATUS=$1; fi 2> /dev/null

	HELP="git gist [--description DESCRIPTION] [--PUBLIC] [--remote REMOTE=origin]"
	if [ 0 -lt $STATUS ]
	then
		echo "$HELP" >&2
	else
		echo "$HELP"
	fi
	exit $STATUS
}


DIR="$( cd "$( dirname "$0" )"; pwd )"


# Initialize options
DESCRIPTION=""
PUBLIC="false"
REMOTE="origin"

# Initialize variables
IS_GIT=0

# Initialize output
GIT_PUSH_URL=""
HTML_URL=""


# Parse --long-options
. "$DIR"/bin/parse-args d: description p public r: remote h help -- "$@"

# Process options
while getopts "$GETOPTS_ARGS" arg
do
	case "$arg" in
	d)
		DESCRIPTION="$OPTARG"
	;;
	p)
		PUBLIC="true"
	;;
	r)
		REMOTE="$OPTARG"
	;;
	h)
		helpquit
	;;
	esac
done


SHOW=$( git remote -v show 2> /dev/null )
# No git Repo yet.  Make one.
if [ 0 -ne $? ]
then
	git init
else
	IS_GIT=1
	git status | grep 'nothing to commit[[:space:][:punct:]]*working directory clean' &> /dev/null
	if [ 0 -ne $? ]
	then
		echo "Please start with a clean working directory!" >&2
		exit 1
	fi
	BRANCH="$( git branch | grep -F '*' | perl -p -e 's/\*\s*//' )"
	if [ "master" != "$BRANCH" ]
	then
		echo "Please start in the master branch!" >&2
		exit 1
	fi
fi


# Bail if we're already a gist
echo "$SHOW" | egrep '^[\w.-]\s+git@gist.github.com:' &> /dev/null
if [ 0 -eq $? ]
then
	echo "Already a Gist :)" >&2
	exit
fi


# JSON encode everything
DESCRIPTION=$( echo -n "$DESCRIPTION" | python -c 'import json; import sys; print json.dumps( sys.stdin.read() )' )


# Fill in the payload template
JSON=$( cat "$DIR/payload/gists.json" )
JSON=${JSON/__DESCRIPTION__/$DESCRIPTION}
JSON=${JSON/__PUBLIC__/$PUBLIC}


# Create gist (includes a placeholder file from the payload)
eval "$( echo "$JSON" | curl -s -H "Authorization: BEARER $(git config --global AutoHub.token)" https://api.github.com/gists -X POST -d @- | "$DIR/"bin/gists.py )"
if [ 0 -ne $? -o -z "$GIT_PUSH_URL" ]
then
	echo "Gist creation failed :(" >&2
	exit 1
fi

# Add the new remote
git remote add "$REMOTE" "$GIT_PUSH_URL"
git fetch
# Pull the placeholder file so we can delete it
git pull "$REMOTE" master
git branch -u "$REMOTE"/master

# Delete the placeholder file
git rm autohub.init > /dev/null

if [ 1 -eq $IS_GIT ]
then
	# Back out to the previous revision (the last "real" one before the placeholder file)
	git reset --hard HEAD~1
else
	# Add everything and commit as first revision
	git add '*'
	git commit --amend -m "init"
fi

# push to gist.  Need to force because of placeholder conflict
git push "$REMOTE" --force

# Done
echo
echo "Created Gist:"
echo "URL: $HTML_URL"
echo "SSH: $GIT_PUSH_URL"
