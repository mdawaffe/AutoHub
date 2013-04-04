#!/usr/bin/env python

"""
Parses the JSON respons from https://api.github.com/user/repos and https://api.github.com/orgs/:org/repos

Used by hubbit.sh
"""

import sys
import json

response = json.loads( sys.stdin.read() )

if not response.get( 'ssh_url' ):
	print >> sys.stderr, "Create Repository request failed :("
	sys.exit( 1 )

print "SSH_URL='%s'" % response['ssh_url']
print "HTML_URL='%s'" % response['html_url']
print "GIT_URL='%s'" % response['git_url']
