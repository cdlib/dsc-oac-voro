"""updates OAC MARC file for use with XTF"""

import pymarc
import os
import sys
import re
from StringIO import StringIO

def update_marc_file(infile, outfile, cdlpath):
    reader = pymarc.MARCReader(file(infile))

    string = StringIO()
    writer = pymarc.MARCWriter(string)

    count = 0
    for record in reader:
        newrecord = pymarc.Record
        count += 1
        field = pymarc.Field(
            tag = '941', 
            indicators = ['0','1'],
            subfields = [ 'a', cdlpath ]
        )
        newrecord = record
        newrecord.rewrite = True
        newrecord.add_field(field)
        writer.write(newrecord)

    print count

    # wait to open the file until the new MARC is ready
    out  = open(outfile, mode="w")
    sys.stdout = out
    print string.getvalue()
    string.close()

# file name of the input MARC
infile = sys.argv[1]

# try to guess the path
pathmatch = re.search('marc/(.*)$', infile)
# die if no pathmatch is found
if pathmatch is None:
    sys.exit("file name does not match required regex")

# the dirname that is left is the cdlpath
cdlpath = os.path.dirname(pathmatch.group(1))
basename = os.path.basename(pathmatch.group(1))

# the directory to write out to
if len(sys.argv) >=3:
    data_dir = sys.argv[2] 
else:
    data_dir = "/dsc/data/xtf/data/marc/"

outfile = data_dir + cdlpath.replace("/",".") + "." + basename + ".marc"

update_marc_file(infile, outfile, cdlpath)
