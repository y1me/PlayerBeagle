!/usr/bin/python
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
