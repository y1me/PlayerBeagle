#!/usr/bin/python
import argparse
import subprocess
import csv
import os 
import re

def BOM_3DtoList(filename, SN_col=2):
    """ convert 3D BOM csv file to a list add column with
    valid a serial number or "UKN" if SN is not valid
    """
    SN_col-=1
    with open(filename,'rb') as csvfile:
        reader = csv.reader(csvfile)
        liste = []
        for row in reader:
            if row[SN_col] != "":
                SN = row[SN_col].partition('_')[0].strip()
                if SN.count('-') != 2 :    
                    row.append("UKN")
                else:
                    if re.search('[a-zA-Z]', SN.partition('-')[-1].rpartition('-')[0]) or re.search('[a-zA-Z]', SN.partition('-')[0].strip()) :
                        row.append("UKN")
                    else:
                        row.append(SN)
                liste.append(row)
        return liste

def ExtractSubAss(listeAss,SubA,RankSubA):
    """Extract Subassembly from 3D BOM
    """
    liste = []
    for row in listeAss:
        if row[0].count('.') == RankSubA and row[0].partition('.')[0].strip() == str(SubA):
            liste.append(row)
    return liste

def HaveChildren(ListofList, pattern):
    """find if pattern is present in a list of list
    """
    result = False
    for row in ListofList:
        if any(pattern in s for s in row):
            result = True
    return result

def StockParent(ListofList, pattern):
    """find and return stock value of a specific part (pattern
    """
    result = '0'
    for row in ListofList:
        if row[0] == pattern:
            result = row[8] 
    return result



parser = argparse.ArgumentParser(description='Create an order file from csv 3D BOM and xlsx stock list')
parser.add_argument('filename',type=str,
                    help='input xlsx file')
parser.add_argument('sheet',type=int,
                    help='input xlsx sheet number')
parser.add_argument('QtyCol',type=int,
                    help='input xlsx QTY column')
parser.add_argument('FNWCol',type=int,
                    help='input xlsx FNW number column')
parser.add_argument('SNCol',type=int,
                    help='input xlsx part serial number column')
parser.add_argument('BOM3Dfile',type=str,
                    help='input csv file')
parser.add_argument('--Qty',
                    dest='toMade',
                    const=10,
                    default=1,
                    action='store',
                    nargs = '?',
                    type=int,
                    help='Numbers of product to made, default 1')
parser.add_argument('-o',
                    dest='fileOutput',
                    default="Output.csv",
                    type=str,
                    help='output file, default Output.csv')


args = parser.parse_args()
sheet = args.sheet - 1
QtyCol = args.QtyCol - 1
FNWCol = args.FNWCol - 1 
SNCol = args.SNCol - 1
ProductNeed = args.toMade
outFile = args.fileOutput


#Import xlsx stock file in a list of list

bashCommand = "ssconvert -S -O 'separator=;' " + args.filename + " doc.txt"
subprocess.call([bashCommand], shell=True, stdout=open(os.devnull, 'w'), stderr=open(os.devnull, 'w'))
# https://docs.python.org/2/library/subprocess.html#frequently-used-arguments
filename = "doc.txt."+ str(sheet)
with open(filename,'rb') as csvfile:
    reader = csv.reader(csvfile,delimiter=';')
    Stocklist = []
    for row in reader:
        if row[SNCol].count('-') == 2:
            Shortlist = []
            Shortlist.append(row[FNWCol])
            Shortlist.append(row[SNCol])
            Shortlist.append(row[QtyCol])
            Stocklist.append(Shortlist)
        elif row[SNCol] != "":
            print "!!!!!!!!!Stock input : row ignored, unknown serial number pattern!!!!!!!!!!!!!!!"
            print row
 
subprocess.call(["rm doc.txt*"], shell=True)



#Import csv 3D BOM file in a list of list
filename = args.BOM3Dfile
BOM3Dlist = BOM_3DtoList(filename,2)
print("!!!!!!!!!!!!!!!!!!!!3D BOM!!!!!!!!!!!!!!!!!!!!!!!!!!!")

for row in BOM3Dlist:
    try:
        row.append( str( ProductNeed*int(row[3]) ) )
    except ValueError:
        row.append("NR")

for rowA in BOM3Dlist:
    for rowB in Stocklist:
        if rowA[4] == rowB[1]:
            rowA.insert(len(rowA)-1,rowB[0])
            rowA.append(rowB[2])

for row in BOM3Dlist:
    if len(row) < 8 :
        row.insert(len(row)-1, "No FNW number")
        row.append('0')

tmp = []
for row in BOM3Dlist:
    row = [data.strip(' ') for data in row]
    tmp.append(row)

BOM3Dlist = tmp

maxIndex = 0
for i in BOM3Dlist:
    if i[0].count('.') == 0:
        if int(i[0]) > maxIndex:
            maxIndex = int(i[0])

FinalData = []
IndexAss = 1
while IndexAss <= maxIndex:
    i = 0
    while ExtractSubAss(BOM3Dlist,IndexAss,i) != []:
        part = ExtractSubAss(BOM3Dlist,IndexAss,i)
        for row in part:
            try:
                Value = str(int(row[6])-int(row[7]))
            except ValueError:
                Value ="Format problem check Stock file"
            if i == 0 and ExtractSubAss(BOM3Dlist,IndexAss,i + 1) == [] : 
                row.append('0')
                row.append(Value)
            elif i == 0 :
                row.append(Value)
                row.append('0')

        
        
            if i != 0 : 
                pattern = row[0].rpartition('.')[0]
                ParentStock = int(StockParent(BOM3Dlist, pattern)) * int(row[3])
                try:
                    Value = str(ParentStock-int(row[7]))
                except ValueError:
                    Value ="Format problem check Stock file"
                if  HaveChildren(BOM3Dlist, row[0]+'.'):
                    row.append(Value)
                    row.append('0')
                else :
                    row.append('0')
                    row.append(Value)
            FinalData.append(row)
        i+=1
    IndexAss += 1

if BOM3Dlist[0][0].find("ARTICLE") > 0:
    BOM3Dlist.pop(0)

tmp = []
for row in BOM3Dlist:
    row = filter(None, row)
    tmp.append(row)

headCol = ["hierarchical assembly reference","Reference","Qty/Product","Part Serial Number","Part FNW Number","Needed Quantity","Quantity in Stock","Quantity to Assemble","Quantity to Order"]  
tmp.insert(0,headCol)
with open(outFile, "w") as f:
    writer = csv.writer(f)
    writer.writerows(tmp)

