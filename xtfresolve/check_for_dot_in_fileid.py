# check for dots in fileid elements
# need to do this to verify correct functioning of 
# xtfresolver

import os
import sys
import lxml.etree as ET

roots = ('13030', '20775', '28722')
dotted_IDS = []
dot_img_ext = []
count=0
for r in roots:
    rootpath = os.path.join(os.environ['HOME'], 'data/xtf/data', r, '00')
    print rootpath
    for root, dirs, files in os.walk(rootpath):
        # DO i want to be a little smart?
        for f in files:
            xf = os.path.splitext(f)
            if xf[1] == '.xml':
                if os.path.splitext(xf[0])[1] == '.mets':
                    #parse file
                    fpath = os.path.join(root, f)
                    tree = ET.parse(fpath)
                    #xpath = ''.join(('(/m:mets/m:fileSec//m:file[@ID="', fileID,
                    #     '"])[1]/m:FLocat[1]/@*[local-name() = \'href\']'))
                    xpath = '/m:mets/m:fileSec//m:file/@*[local-name() = \'ID\']'
                    namespaces = { 'm': 'http://www.loc.gov/METS/',
                       'xlink': 'http://www.w3.org/TR/xlink'}
                    fileids = tree.xpath(xpath, namespaces=namespaces)  
                    for fid in fileids:
                        count=count+1
                        if count%100 == 0:
                            print "Checked %d FILEIDS: current file: %s" % (count, fpath)
                            sys.stdout.flush()
                        if '.' in fid:
                            dotted_IDS.append((fpath, fid))
                            print fid, ' :: ', fid.rsplit('.', 1)
                            if fid.rsplit('.', 1)[1] in ('jpg', 'gif', 'jpeg'):
                                dot_img_ext.append((fpath, fid))

print "____________________"
print "____________________"
print "____________________"
print "Dotted FILEIDS:", len(dotted_IDS), "  IMAGE ext:", len(dot_img_ext)
print "PROBLEMS::::"
for path, fid in dot_img_ext:
    print path, fid
