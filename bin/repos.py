#!/usr/bin/env python

import sys
import json

response = json.loads( sys.stdin.read() )

if not response.get( 'ssh_url' ):
	print >> sys.stderr, "Create Repository request failed :("
	sys.exit( 1 )

print "SSH_URL='%s'" % response['ssh_url']
print "HTML_URL='%s'" % response['html_url']
print "GIT_URL='%s'" % response['git_url']
