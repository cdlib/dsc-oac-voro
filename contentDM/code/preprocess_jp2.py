#! /usr/bin/env python

# Process URLs for contentdm exports that point at JPEG 2000 files.
# Ran on input on a ad-hoc basis.
# saves original EAD as .xml.bak
# input parameter is the EAD file path
import sys
#import os
import shutil
import re

PGM_RE = re.compile('showfile.exe')
PGM_SUB = 'getimage.exe'
SIMPLE_OBJ_URL_RE = re.compile(r'</structure>')
COMPLEX_OBJ_URL_RE = re.compile(r'getimage\.exe(.+)</pagefilelocation>')
URL_ADD = r'&amp;DMWIDTH=100000&amp;DMHEIGHT=100000' # handle up to 10000 px jp2

def main(args):
    if len(args) < 2:
        print "Usage: ",__file__," /path/to/cdm_export <image_scale>"
        sys.exit(1)
    ead_file = args[1]
    image_scale = 100
    if len(args)==3:
    	image_scale = int(args[2])
    print "USING IMAGE SCALE: ", str(image_scale)
    simple_obj_url_sub = URL_ADD + '&amp;DMSCALE=' + str(image_scale) + '</structure>'
    complex_obj_url_sub = URL_ADD + '&amp;DMSCALE=' + str(image_scale) + '</pagefilelocation>'
    ead_bak = ead_file+'.bak'
    shutil.copy(ead_file, ead_bak)
    fin = open(ead_bak, 'r')
    fout = open(ead_file, 'w')
    for line in fin.readlines():
        matchobj = COMPLEX_OBJ_URL_RE.search(line)
        if matchobj:
            print "++++++ COMPLEX IN +++++", ead_file
            substitution = 'getimage.exe'+matchobj.group(1)+complex_obj_url_sub
            newline = COMPLEX_OBJ_URL_RE.sub(substitution, line)
        else:
            newline = line
        newline = PGM_RE.sub(PGM_SUB, newline)
        if newline != line:
            newline = SIMPLE_OBJ_URL_RE.sub(simple_obj_url_sub, newline)
        fout.write(newline)
    fin.close()
    fout.close()

if __name__=="__main__":
    main(sys.argv)
