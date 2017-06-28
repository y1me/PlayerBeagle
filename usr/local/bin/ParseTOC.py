#!/usr/bin/python
import argparse

TOC="/ramtmp/toc"
TOCABS="/ramtmp/tocabsolute"


def FormatTocABS():
	"""convert tracks duration in seconds
	"""
	i=1
	result=""
	seconds=0.00
	fout=open(TOCABS,'w')
	with open(TOC,'r') as f:
		for line in f:
			if line.count("[") == 1:
				length=line[line.find("[")+1:line.find("]")]
				#print length
				#print length.partition(':')[0]
				#print length.partition(':')[1]
				#print length.partition(':')[2]
				tr=float( length.partition(':')[0] ) * 60.00 + float( length.partition(':')[2] )
				#print tr
				seconds = seconds + tr
				#print round(seconds,1) 
				#print seconds
				fout.write(str(round(seconds,1)) + "\n") 
	fout.close()

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
parser.add_argument("-d","--toctoseconds",
                    help="format toc to seek tracks" ,
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
if args.toctoseconds:
	total=FormatTocABS()