#!/usr/bin/python
import os, sys

if len(sys.argv) > 1:
    args = sys.argv[1:]
else:
    args = ['bash']

os.execvp('bash', args)
