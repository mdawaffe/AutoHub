#!/usr/bin/env bash

function helpquit {
	STATUS=0
	if [ $1 -ge 0 ]; then STATUS=$1; fi 2> /dev/null

	HELP="git hubbit --name NAME [--description DESCRIPTION] [--private] [--org ORGANIZATION] [--team TEAM_ID] [--remote REMOTE=origin]"
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
NAME=""
DESCRIPTION=""
PRIVATE="false"
ORG=""
TEAM=""
REMOTE="origin"

# Initialize variables
BRANCH="master"

# Initialize output
SSH_URL=""
HTML_URL=""
GIT_URL=""


# Parse --long-options
. "$DIR"/bin/parse-args n: name d: description P private r: remote o: org t: team h help -- "$@"

# Process options
while getopts "$GETOPTS_ARGS" arg
do
	case "$arg" in
	n)
		NAME="$OPTARG"
	;;
	d)
		DESCRIPTION="$OPTARG"
	;;
	P)
		PRIVATE="true"
	;;
	o)
		ORG="$OPTARG"
	;;
	t)
		TEAM="$OPTARG"
	;;
	r)
		REMOTE="$OPTARG"
	;;
	h)
		helpquit
	;;
	esac
done

# NAME is required
if [ -z "$NAME" ]
then
	helpquit 1
fi


SHOW=$( git remote -v show 2> /dev/null )
if [ 0 -ne $? ]
then
	# No git Repo yet.  Make one.
	git init
fi

echo "$SHOW" | egrep '^[\w-]+\s+git@github.com:' &> /dev/null
if [ 0 -eq $? ]
then
	echo "Already on GitHub :)" >&2
	exit
fi

BRANCH="$( git branch | grep -F '*' | perl -p -e 's/\*\s*//' )"

if [ -z "$BRANCH" ]
then
	ls README README.* &> /dev/null
	if [ 0 -ne $? ]
	then
		touch README.md
	fi
	git add README 2> /dev/null
	git add README.* 2> /dev/null
	git commit -m "readme"
	BRANCH="$( git branch | grep -F '*' | perl -p -e 's/\*\s*//' )"
fi
	

# JSON encode everything
NAME=$( echo -n "$NAME" | python -c 'import json; import sys; print json.dumps( sys.stdin.read() )' )
DESCRIPTION=$( echo -n "$DESCRIPTION" | python -c 'import json; import sys; print json.dumps( sys.stdin.read() )' )
TEAM=$( echo -n "$TEAM" | python -c 'import json; import sys; print json.dumps( sys.stdin.read() )' )


# Fill in the payload template
JSON=$( cat "$DIR/payload/repos.json" )
JSON=${JSON/__NAME__/$NAME}
JSON=${JSON/__DESCRIPTION__/$DESCRIPTION}
JSON=${JSON/__ORG__/$ORG}
JSON=${JSON/__TEAM__/$TEAM}
JSON=${JSON/__PRIVATE__/$PRIVATE}


# Personal or organizational repository?
URL="https://api.github.com/user/repos"
if [ -n "$ORG" ]
then
	URL="https://api.github.com/orgs/$ORG/repos"
fi

# Create repository
eval "$( echo "$JSON" | curl -s -H "Authorization: BEARER $(git config --global AutoHub.token)" "$URL" -X POST -d @- | "$DIR/"bin/repos.py )"
if [ 0 -ne $? -o -z "$SSH_URL" ]
then
	echo "GitHub Repository creation failed :(" >&2
	exit 1
fi


# Add the new remote and push
git remote add "$REMOTE" "$SSH_URL"
git push "$REMOTE" "$BRANCH"

# Done
echo
echo "Created GitHub Repository:"
echo "URL:       $HTML_URL"
echo "READ-ONLY: $GIT_URL"
echo "SSH:       $SSH_URL"
