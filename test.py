#!/usr/bin/python

i=1
with open("/ramtmp/toc",'r') as f:
	for line in f:
		print "this is line {:03d}".format(i)
		print line.partition(':')[0]
		print line.partition('[')[-1].rpartition(']')[0]
		print line.partition(']')[-1]
		i+=1
