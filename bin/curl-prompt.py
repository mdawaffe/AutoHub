#!/usr/bin/env python

import sys

line = ""
while True:
	c = sys.stdin.read(1)

	line = line + c

	if ":" == c:
		line = line + " "
		sys.stdout.write( line.replace( "host", "GitHub" ) )
		sys.stdout.flush()
	if not c:
		break

print
