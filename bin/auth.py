#!/usr/bin/env python

import sys
import json

response = json.loads( sys.stdin.read() )

if not response.get( 'id' ) or not response.get( 'token' ):
	print >> sys.stderr, "Token Request Failed :("
	sys.exit( 1 )

print "AUTOHUB_ID='%s'" % response['id']
print "AUTOHUB_TOKEN='%s'" % response['token']
