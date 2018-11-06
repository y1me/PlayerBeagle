#!/usr/bin/python
import argparse

TOC="/ramtmp/toc"
TOCABS="/ramtmp/tocabsolute"


def TrackInfo(number):
	"""find and return a track duration and title
	"""
	i=1
	result=""
	seconds=0.00
	fout=open(TOCABS,'w')
	with open(TOC,'r') as f:
		for line in f:
			if line.count("[") == 1:
				length=line[line.find("[")+1:line.find("]")]
				tr=float( length.partition(':')[0] ) * 60.00 + float( length.partition(':')[2] )
				seconds = seconds + tr
				fout.write(str(round(seconds,1)) + "\n") 
	fout.close()

def TrackTitle(number):
	"""find and return a track title
	"""
	result=""
        if number > TotalTracks():
            exit(1)
	with open(TOC,'r') as f:
		for line in f:
                    if line.partition('=')[0].strip() == ("TTITLE" + str(int(number) -1)):
                        return line.partition('=')[-1].strip()
		exit(1)


def AlbumTitle():
	"""find and return a Album title
	"""
	with open(TOC,'r') as f:
		for line in f:
			if line.partition('=')[0].strip() == "DTITLE":
				return line.partition('=')[2].partition('/')[2].strip()
		exit(1)

def Artist():
	"""find and return a Artist
	"""
	with open(TOC,'r') as f:
		for line in f:
			if line.partition('=')[0].strip() == "DTITLE":
				return line.partition('=')[2].partition('/')[0].strip()
                exit(1)	

def TotalTracks():
	"""find and return a Total tracks
	"""
	with open(TOC,'r') as f:
            line = f.readline().strip()
            if len(line.split()[1]) < 2:
                return "0" + line.split()[1]
            return line.split()[1]

def DiscLength():
	"""find and return a disc length
	"""
	with open(TOC,'r') as f:
            line = f.readline().strip()
            return line.split()[-1]

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
                    help="return disc length (seconds)" ,
		    action="store_true")
parser.add_argument("-c","--disctotal",
                    help="return total tracks and disc length (seconds)" ,
		    action="store_true")
parser.add_argument("-d","--trackinfo",
                    dest='TrackInfo',
                    default="",
                    type=str,
                    help="return track info" )
                    
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
	print total
if args.TrackInfo:
	total=FormatTocABS()
