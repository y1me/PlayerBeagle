#!/usr/bin/python
import argparse

TOC="/ramtmp/toc"


def TrackTitle(number):
	"""find and return a track title
	"""
	i=1
	result=""
	with open(TOC,'r') as f:
		for line in f:
			if line.partition(':')[0].strip() == number:
				#print "this is line {:03d}".format(i)
				#print line.partition(':')[0]
				#print line.partition('[')[-1].rpartition(']')[0]
				return line.partition(']')[-1]
			i+=1
		return result


parser = argparse.ArgumentParser(description='Return cd toc info')
parser.add_argument("-t","--tracktitle",
                    dest='TrackNumber',
                    default="",
                    type=str,
                    help="return track title of a track number" )
                    
args = parser.parse_args()
print TrackTitle(args.TrackNumber)
