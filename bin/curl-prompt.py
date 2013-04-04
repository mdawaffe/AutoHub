#!/usr/bin/env python

"""
curl -u outputs the following password prompt (where the underscore is the input cursor).
Enter host password for user 'foo':_
I could not figure out how to manipulate that text directly via the shell since it does not contain a newline.
This file reads the prompt as a character stream and customizes the text.

Used by install.sh
"""

import sys

line = ""
while True:
	# Blocks at the end of the string while we wait for the user to enter a password
	# since it hasn't yet seen an EOF
	c = sys.stdin.read(1)

	line = line + c

	if ":" == c:
		# Add a visual space after the prompt
		line = line + " "
		# Make it obvious we need the GitHub password
		sys.stdout.write( line.replace( "host", "GitHub" ) )
		# Flush immediately to make sure the prompt shows up on screen
		sys.stdout.flush()
	if not c:
		break

# After we get an EOF (after the user has entered a password),
# print a newline
print
