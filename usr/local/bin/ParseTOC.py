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
				return line.partition(']')[-1].strip()
			i+=1
		return result

def AlbumTitle():
	"""find and return a Album title
	"""
	i=1
	result=""
	with open(TOC,'r') as f:
		for line in f:
			if line.partition(':')[0].strip() == "Album name":
				#print "this is line {:03d}".format(i)
				#print line.partition(':')[0]
				#print line.partition('[')[-1].rpartition(']')[0]
				return line.partition(':')[2].strip()
			i+=1
		return result

def Artist():
	"""find and return a Artist
	"""
	i=1
	result=""
	with open(TOC,'r') as f:
		for line in f:
			if line.partition(':')[0].strip() == "Album artist":
				#print "this is line {:03d}".format(i)
				#print line.partition(':')[0]
				#print line.partition('[')[-1].rpartition(']')[0]
				return line.partition(':')[2].strip()
			i+=1
		return result

def TotalTracks():
	"""find and return a Total tracks
	"""
	i=1
	result=""
	with open(TOC,'r') as f:
		for line in f:
			if line.partition(':')[0].strip() == "Total tracks":
				#print "this is line {:03d}".format(i)
				#print line.partition(':')[0]
				#print line.partition('[')[-1].rpartition(']')[0]
				result=line.partition(':')[2]
				return result.partition("Disc length")[0].strip()
			i+=1
		return result

def DiscLength():
	"""find and return a disc lendgth
	"""
	i=1
	result=""
	with open(TOC,'r') as f:
		for line in f:
			if line.partition(':')[0].strip() == "Total tracks":
				#print "this is line {:03d}".format(i)
				#print line.partition(':')[0]
				#print line.partition('[')[-1].rpartition(']')[0]
				result=line.partition(':')[2]
				return result.partition("Disc length:")[2].strip()
			i+=1
		return result

parser = argparse.ArgumentParser(description='Return cd toc info')
parser.add_argument("-t","--tracktitle",
                    dest='TrackNumber',
                    default="",
                    type=str,
                    help="return track title of a track number" )
parser.add_argument("-n","--albumtitle",
                    help="return album title" ,
		    action="store_true")
parser.add_argument("-a","--artist",
                    help="return artist" ,
		    action="store_true")
parser.add_argument("-b","--totaltracks",
                    help="return number of tracks" ,
		    action="store_true")
parser.add_argument("-l","--disclength",
                    help="return disc length" ,
		    action="store_true")
parser.add_argument("-c","--disctotal",
                    help="return total tracks and disc length" ,
		    action="store_true")
                    
args = parser.parse_args()
if args.TrackNumber:
	print TrackTitle(args.TrackNumber)
if args.albumtitle:
	print AlbumTitle()
if args.artist:
	print Artist()
if args.totaltracks:
	print TotalTracks()
if args.disclength:
	print DiscLength()
if args.disctotal:
	total=TotalTracks()+DiscLength()
	total=total.replace(":","")
	print total
