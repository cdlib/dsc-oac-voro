"""updates OAC MARC file for use with XTF"""

import pymarc
import os
import sys
import re
import codecs
import StringIO

def update_marc_file(infile, outfile, cdlpath):
    """add cdlpath info to all the MARC records in a file"""
    # open MARC file for reading
    reader = pymarc.MARCReader(
      file(infile),
      to_unicode=True, 
      force_utf8=True, 
      utf8_handling='ignore'
    )

    # keep the new file in memory
    string = StringIO.StringIO()
    writer = pymarc.MARCWriter(string)

    # main look through all the records
    count = 0
    for record in reader:
        count += 1
        # create new MARC field and add it to the record
        field = pymarc.Field(
            tag = '941', 
            indicators = ['0','1'],
            subfields = [ 'a', cdlpath ]
        )
        record.add_field(field)

        # write the records in a try to catch unicode errors
        try:
            writer.write(record)
        except UnicodeDecodeError as inst:
            title = ''
            recordId = ''
            if record['245'] is not None:
                title = record['245']
            if record['001'] is not None:
                recordId = record['001']
            print "--- error with record %s %s" % (count, recordId) 
            print "leader9 = %s" % record.leader[9]
            print title
            print inst
            print "\n"

    out  = open(outfile, mode="w")
    sys.stdout = out
    print string.getvalue()
    string.close()

# could wrap the stuff below in a "main"

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
