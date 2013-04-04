#!/usr/bin/env python

"""
Parses the JSON response from https://api.github.com/gists

Used by gist.sh
"""


import sys
import json

response = json.loads( sys.stdin.read() )

if not response.get( 'git_push_url' ):
	print >> sys.stderr, "Gist Request Failed :("
	sys.exit( 1 )

print "GIT_PUSH_URL='%s'" % response['git_push_url'].replace( "https://gist.github.com/", "git@gist.github.com:" )
print "HTML_URL='%s'" % response['html_url']
