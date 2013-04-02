#!/usr/bin/env python

import sys
import json

response = json.loads( sys.stdin.read() )

if not response.get( 'git_push_url' ):
	print >> sys.stderr, "Gist Request Failed :("
	sys.exit( 1 )

print "GIST_URL='%s'" % response['git_push_url'].replace( "https://gist.github.com/", "git@gist.github.com:" )

