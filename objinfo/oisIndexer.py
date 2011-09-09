#!/usr/bin/env python

# The Object information service indexer. Creates the Institution name based
# mapping db for use by the Object Info Service

import os
import sys
import os.path
import datetime
import pysqlite2._sqlite as sqlite
import lxml.etree as ET
import glob
import csv
import re
import MySQLdb
from config_reader import read_config

DEBUG = os.environ.get('DEBUG', False)
HOME = os.environ['HOME']

DIR_ROOT = HOME + '/data/in/oac-ead/prime2002/'
DB_FILE = HOME + '/indexes/sqlite3/ois.sqlite3'
db = read_config()

DB_MYSQL_NAME = db['default-ro']['NAME']
DB_MYSQL_USER = db['default-ro']['USER']
DB_MYSQL_PASSWORD = db['default-ro']['PASSWORD']
DB_MYSQL_HOST = db['default-ro']['HOST']
DB_MYSQL_PORT = db['default-ro']['PORT']

DIR_ORPHANS =  os.path.split(os.path.realpath(__file__))[0] + '/orphans/'

REGEX_ARK = re.compile("ark:/(?P<NAAN>\d{5}|\d{9})/([a-zA-Z0-9=#\*\+@_\$/%-\.]+)$")

def run_samples():
    DIR_SAMPLES_ROOT = HOME + '/data/in/oac-ead/prime2002/'
    samples = [("A","ark:/13030/tf10000759"),
    ("B","ark:/13030/kt200014h4"),
    ("C","ark:/13030/kt196nc93r"),
    ("D","ark:/13030/tf6r29p0kq"),
    ("E","ark:/13030/tf0199n71x"),
    ("F","ark:/13030/ft596nb1jf"),
    ("G","ark:/13030/ft838nb5kh"),
    ("H","ark:/13030/kt4f59q9k8"),
    ("I","ark:/13030/kt9d5nd53d"),
    ("J","ark:/13030/tf096nb0j1"),
    ("K","ark:/13030/kt62902688"),
    ("L","ark:/13030/kt7r29q3gq"),
    ("M","ark:/13030/kt5p3020w9"),
    ("N","ark:/13030/kt85801594"),
    ("O","ark:/13030/kt8z09p8pd"),
    ("P","ark:/13030/tf967nb619"),
    ("Q","ark:/13030/kt7489n9gs"),
    ("R","ark:/13030/ft358004x0"),
    ("S","ark:/13030/tf8r29p24k"),
    ("T","ark:/13030/kt3s2004xw"),
    ("U","ark:/13030/kt2199p9w7"),
    ("V","ark:/13030/tf9k4009f8"),
    ("W","ark:/13030/kt096n97b6"),
    ("X","ark:/13030/tf7p3006fv"),
    ("Y","ark:/13030/tf238n986k"),
    ("Z","ark:/13030/tf258001r8"),
    ("AA","ark:/13030/tf4290044c"),
    ("AB","ark:/13030/kt6b69q574"),
    ("AC","ark:/13030/kt500023mk"),
    ("AD","ark:/13030/kt0n39q6hv"),
    ("AE","ark:/13030/tf338n99v6"),
    ("AF","ark:/13030/kt5p3019m2"),
    ("AG","ark:/13030/tf7290056t"),
    ]
    
    
    for (i, ark) in samples:
        id = ark.rsplit("/",1)[1]
        dir_sub = id[-2:]
        foo = os.path.join(DIR_ROOT, dir_sub, id, id+".xml")
        #if i == 'AF':
        load_findingaid(foo)

def isXMLfile(fname):
    '''Checks file name to ensure file is just a <foo>.xml
    '''
    (name, ext) = os.path.splitext(fname)
    if ext == '.xml':
        #check if extra . in name (.mets.xml etc)
        (n2, ext2) = os.path.splitext(name)
        if not ext2:
            return True
    return False

def parse_findingaid(findingaid):
    '''Parse a findingaid EAD file.
    Input is fullpath name of file.
    Returns a tuple of findingaid ark, parent ark, grandparent ark and ordered
    list of dao/daogrp arks. Do dao & daogrp appear in one finding aid?
    '''
    if not os.path.isfile(findingaid):
        print findingaid
        raise Exception

    try:
        tree = ET.parse(findingaid)
    except ET.XMLSyntaxError, instance:
        print "ET.XMLSyntaxError : %s" % str(instance)
        print instance.msg
        sys.stdout.flush()
        return None, None, None, None

    eadid = tree.find("//eadid")
    if eadid is None:
        print "No eadid for file:%s" % findingaid
        sys.stdout.flush()
        return None, None, None, None
    ark_findingaid = eadid.attrib.get('identifier')
    ark_parent = eadid.attrib.get('{http://www.cdlib.org/path/}parent')
    ark_grandparent = eadid.attrib.get('{http://www.cdlib.org/path/}grandparent')
    digobjs = tree.findall("//dao")
    if len(digobjs) == 0:
        digobjs = tree.findall("//daogrp")
    ark_daos = []
    for digobj in digobjs:
        id_obj = digobj.attrib.get('poi')
        if id_obj is None:
            # try  different node for ark:
            id_href = digobj.attrib.get('href')
            #print "id_href = ", id_href.encode('utf-8'), "for FA = ", findingaid.encode('utf-8')
            if id_href is not None:
                #try to get an OAC ark, objs on other sites in general  
                # don't have these
                # for our style hrefs they will end in ark:/XXXXX/XXXXXX
                try:
                    id_obj = id_href[id_href.index("ark:"):]
                except ValueError:
                    pass
        if id_obj is not None:
            ark_daos.append(id_obj)
    return ark_findingaid, ark_parent, ark_grandparent, ark_daos

def add_ark_to_db(ark_object, ark_parent, ark_grandparent=None, ark_daos=None):
    #there are some daos for this finding aid, so make db entries
    conn = MySQLdb.connect(host=DB_MYSQL_HOST, user=DB_MYSQL_USER,
                               passwd=DB_MYSQL_PASSWORD, db=DB_MYSQL_NAME,
                               port=int(DB_MYSQL_PORT)
                              )
    google_analytics_tracking_code = ''
    if ark_grandparent == None:
        #Lookup parent ark in DB & see if a parent for it exists
        #conn = MySQLdb.connect(host=DB_MYSQL_HOST, user=DB_MYSQL_USER,
        #                       passwd=DB_MYSQL_PASSWORD, db=DB_MYSQL_NAME,
        #                       port=int(DB_MYSQL_PORT)
        #                      )
        c = conn.cursor()
        #c.execute("""SELECT parent_institution_id from oac_institution where ark=%s""", (ark_parent,))
        c.execute("""SELECT google_analytics_tracking_code, name, id from oac_institution where ark=%s""", (ark_parent,))
        google_analytics_tracking_code, inst_name, inst_id = c.fetchone()
        id_parent = inst_id
        if id_parent:
            c.execute("""SELECT ark from oac_institution where id=%s""",
                      (id_parent,))
            ark_grandparent = c.fetchone()[0]
        conn.close()
    else: #grandparent is inst???
        c = conn.cursor()
        c.execute("""SELECT google_analytics_tracking_code, name, id from oac_institution where ark=%s""", (ark_grandparent,))
        google_analytics_tracking_code, inst_name, inst_id = c.fetchone()
        conn.close()


    conn = sqlite.connect(DB_FILE)
    c = conn.cursor()
    c.execute("""insert or replace into item
              (ark, ark_parent, ark_grandparent, google_analytics_tracking_code)
              VALUES (?, ?, ?, ?)""", (ark_object, ark_parent,
                                    (ark_grandparent,
                                     '')[ark_grandparent is None],
                                    google_analytics_tracking_code
                                   )
             )
    if ark_daos:
        num_daos = len(ark_daos)
        for order, ark_dao in enumerate(ark_daos):
            #XTF has string sort only, so pad numeric order value
            #and store as padded string in db.
            for x in range(1,9):
                p10 = 10 ** x
                if p10 > num_daos:
                    order_format = "%0" + str(x) + "d"
                    break
            order_str = order_format % order
            c.execute("""insert or replace into digitalobject
                       (ark, ark_findingaid, "num_order", google_analytics_tracking_code )
                       VALUES (?, ?, ?, ?)""", (ark_dao, ark_object, order_str, google_analytics_tracking_code)
                     )
    conn.commit()
    conn.close()

def load_findingaid(findingaid):
    '''Loads the digital object list information for a finding aid.
    Input is fullpaht name of EAD file.
    No output
    '''
    ark_findingaid, ark_parent, ark_grandparent, ark_daos = parse_findingaid(findingaid)
    add_ark_to_db(ark_findingaid, ark_parent, ark_grandparent, ark_daos)
    if DEBUG:
        print "Added %s : ark_EAD:%s" % (findingaid, ark_findingaid)
        for a in ark_daos:
            print '++++ DAO in EAD %s - %s' % (ark_findingaid, a)
        sys.stdout.flush()

def process_findingaids():
    # use os.walk to recurse, open any .xml files & parse with ET
    for dirpath, dirs, files in os.walk(DIR_ROOT):
        if files:
            for foo in files:
                filepath = os.path.join(dirpath, foo)
                if isXMLfile(filepath):
                    load_findingaid(filepath)

def process_orphans():
    '''Add 'orphan' texts to the object service. This reads any *.orphans files
    in the orphans directory and parses the csv separated lising of
    object ark, parent inst ark. It then create entries in the sqlite db.
    '''
    foo_orphans = glob.glob(DIR_ORPHANS+'*.orphans')
    for f in foo_orphans:
        if DEBUG:
            print f
        fh = open(f,'r')
        reader = csv.reader(fh)
        for row in reader:
            add_ark_to_db(row[0], row[1])
        fh.close()

if __name__=="__main__":
    time_start = datetime.datetime.now()
    process_findingaids()
    process_orphans()
    time_finish = datetime.datetime.now()
    time_delta = time_finish - time_start
    print "OIS Finished indexing digital objects"
    print "Started:%s Finished:%s Elapsed:%s" % (time_start, time_finish,
