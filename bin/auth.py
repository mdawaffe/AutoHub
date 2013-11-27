#!/usr/bin/env python

"""
Parses the JSON response from https://api.github.com/authorizations

Used by install.sh
"""

import sys
import json

response = sys.stdin.read()
header_lines, body = response.split( "\r\n\r\n" )
headers = {}
for header_line in header_lines.split( "\n" ):
	try:
		header, sep, value = header_line.partition( ':' )
		headers[header.lower()] = value.strip()
	except:
		pass


if 'x-github-otp' in headers and headers['x-github-otp'].startswith( 'required' ):
	print "OTP"
	sys.exit( 1 )

body = json.loads( body )

if not body.get( 'id' ) or not body.get( 'token' ):
	print >> sys.stderr, "Token Request Failed :("
	sys.exit( 1 )

print "AUTOHUB_ID='%s'" % body['id']
print "AUTOHUB_TOKEN='%s'" % body['token']
