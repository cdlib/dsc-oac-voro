# Provides the ois (Object Info Service) cgi interface
# Input: ark of dao, finding aid ark (ark_parent)
# Returns: order of dao in parent
# name of parent institution
# name of grandparent institution
# google_analytics_tracking_code for parent institution

import sqlite3 as sqlite
import MySQLdb
import sys
import cgi
import re
from xml.sax.saxutils import escape
import os
from config_reader import read_config

HOME = os.environ['HOME']
DB_SQLITE = HOME + '/indexes/sqlite3/ois.sqlite3'
DB_SQLITE_TEST = './test/ois-test.sqlite3'

db = read_config()
DB_KEY = os.environ['DSC_DATABASE']+'-ro'

DB_MYSQL_NAME = db[DB_KEY]['NAME']
DB_MYSQL_USER = db[DB_KEY]['USER']
DB_MYSQL_PASSWORD = db[DB_KEY]['PASSWORD']
DB_MYSQL_HOST = db[DB_KEY]['HOST']
DB_MYSQL_PORT = db[DB_KEY]['PORT']

def lookup_inst_info(ark_parent, ark_grandparent=None):
    '''For given ark, lookup the name in the Django DB
    '''
    conn = MySQLdb.connect(host=DB_MYSQL_HOST, user=DB_MYSQL_USER,
                           passwd=DB_MYSQL_PASSWORD, db=DB_MYSQL_NAME,
                           port=int(DB_MYSQL_PORT)
                          )
    c = conn.cursor()
    c.execute("""SELECT name, url, google_analytics_tracking_code from oac_institution where ark=%s""", (ark_parent,))
    name_parent, url_parent, gacode = c.fetchone()
    if ark_grandparent:
        c.execute("""SELECT name, url from oac_institution where ark=%s""",
                  (ark_grandparent,))
        name_grandparent, url_grandparent, = c.fetchone()
    else:
        name_grandparent = url_grandparent = None
    conn.close()
    return name_parent, url_parent,  name_grandparent, url_grandparent, gacode

def lookup_info(ark, ark_parent, db=DB_SQLITE):
    '''Lookup item information in the ois.sqlite3 database.
    Returns the order of the object (for simple objs this is -1), name and ark
    of the contributing institution, name & ark of the parent institution if
    the contributing institution has a parent and 
    the google analytics tracking code for the owning institution.
    The ark is either the ark of the object or finding aid. If a parent_ark is 
    supplied it should be the ark of the object's finding aid.

    >>> x=lookup_info('ark:/13030/kt796nb207', db=DB_SQLITE_TEST)
    Traceback (most recent call last):
      File "<input>", line 1, in <module>
    TypeError: lookup_info() takes at least 2 non-keyword arguments (1 given)
    >>> x=lookup_info('ark:/13030/kt796nb207', None, db=DB_SQLITE_TEST)
    Traceback (most recent call last):
        ...
    KeyError: 'ARK ark:/13030/kt796nb207 for object not found in item db'
    >>> x=lookup_info('ark:/13030/hb9j49p55', 'ark:/13030/kt0g5016h6', db=DB_SQLITE_TEST)
    >>> x
    (-1, 'Ethnic Studies Library', u'ark:/13030/kt4b69n6wx', 'http://eslibrary.berkeley.edu/', 'UC Berkeley', u'ark:/13030/tf0p3009mq', 'http://www.lib.berkeley.edu/', '')
    >>> x=lookup_info('ark:/13030/tf2c600703', 'ark:/13030/tf7s2010k4',  db=DB_SQLITE_TEST)
    >>> x
    (u'073', 'Bancroft Library', u'ark:/13030/tf7r29p8s0', 'http://bancroft.berkeley.edu/', 'UC Berkeley', u'ark:/13030/tf0p3009mq', 'http://www.lib.berkeley.edu/', 'UA-31403262-1')
    >>> x=lookup_info('ark:/13030/kt3199n606', None,  db=DB_SQLITE_TEST)
    Traceback (most recent call last):
        ...
    KeyError: 'ARK ark:/13030/kt3199n606 for object not found in item db'
    >>> x=lookup_info('ark:/13030/kt5m3nb0t1', None, db=DB_SQLITE_TEST)
    >>> x
    (-1, 'Scripps Institution of Oceanography Archives', u'ark:/13030/tf22901027', 'http://libraries.ucsd.edu/locations/sio/scripps-archives', 'Scripps Institution of Oceanography Archives', u'ark:/13030/tf22901027', 'http://libraries.ucsd.edu/locations/sio/scripps-archives', 'UA-32908996-1')
    >>> x=lookup_info('ark:/13030/kt538nb0tr', None, db=DB_SQLITE_TEST)
    >>> x
    (-1, 'Scripps Institution of Oceanography Archives', u'ark:/13030/tf22901027', 'http://libraries.ucsd.edu/locations/sio/scripps-archives', 'Scripps Institution of Oceanography Archives', u'ark:/13030/tf22901027', 'http://libraries.ucsd.edu/locations/sio/scripps-archives', 'UA-32908996-1')
    >>> x=lookup_info('ark:/13030/kt787014q6', None, db=DB_SQLITE_TEST)
    >>> x
    (-1, 'Special Collections', u'ark:/13030/tf1489p250', 'http://www.lib.ucdavis.edu/specol/', 'Special Collections', u'ark:/13030/tf1489p250', 'http://www.lib.ucdavis.edu/specol/', 'UA-30635447-1')
    >>> x=lookup_info('ark:/13030/hb4k400701', None, db=DB_SQLITE_TEST)
    Traceback (most recent call last):
      ...
    KeyError: 'ARK ark:/13030/hb4k400701 for object not found in item db'
    >>> x=lookup_info('ark:/13030/kt4779q8sk', None, db=DB_SQLITE_TEST)
    >>> x
    (-1, 'Chabot Space and Science Center', u'ark:/13030/kt5489q9r6', 'http://www.chabotspace.org/', None, None, None, '')
    '''
    google_analytics_tracking_code = None
    num_order = -1
    conn = sqlite.connect(db)
    c = conn.cursor()
    if ark_parent:
        #lookup digital object order
        c.execute('''SELECT num_order from digitalobject where ark=? and
                  ark_findingaid=?''', (ark, ark_parent)
                 )
        rowdata = c.fetchone()
        if rowdata:
            num_order = rowdata[0]
    c.execute('''SELECT ark_parent, ark_grandparent from item where ark=?''', (ark, )
             )
    rowdata = c.fetchone()
    if not rowdata:
        if not ark_parent:
            raise KeyError('ARK %s for object not found in item db' % (ark,))
        c.execute('''SELECT ark_parent, ark_grandparent from item where ark=?''', (ark_parent, )
             )
        rowdata = c.fetchone()
        if not rowdata:
            raise KeyError('ARK %s for finding aid not found in item db' % (ark_parent, ))
    ark_parent, ark_grandparent = rowdata
    name_parent, url_parent, name_grandparent, url_grandparent, google_analytics_tracking_code = lookup_inst_info(ark_parent, ark_grandparent)
    conn.close()
    return num_order, name_parent, ark_parent, url_parent,  name_grandparent, ark_grandparent, url_grandparent, google_analytics_tracking_code

# WSGI interface here.
def application(environ, start_response):
    '''WSGI application for Object Info Service

    >>> from webtest import TestApp
    >>> from webob import Request, Response
    >>> app = TestApp(application)
    >>> res = app.get('/wsgi/ois_service/')
    Traceback (most recent call last):
    ...
    AppError: Bad response: 400 NO ARKS (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service/)
    '<h1>NO ARK PARAMETERS</h1>'
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=ark:/13030/tf0v19n4gf')
    Traceback (most recent call last):
    ...
    AppError: Bad response: 400 INCORRECT ARK FORMAT (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=ark:/13030/tf0v19n4gf)
    '<H1>ERROR: INCORRECT ARK FORMAT</H1>'
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=')
    Traceback (most recent call last):
    ...
    AppError: Bad response: 400 INCORRECT ARK FORMAT (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=)
    '<H1>ERROR: INCORRECT ARK FORMAT</H1>'
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/X3030/tf0v19n4gf')
    Traceback (most recent call last):
    ...
    AppError: Bad response: 400 INCORRECT ARK FORMAT (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/X3030/tf0v19n4gf)
    '<H1>ERROR: INCORRECT ARK FORMAT</H1>'
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/13030/xtf0v19n4gf')
    Traceback (most recent call last):
    ...
    AppError: Bad response: 400 ARK NOT FOUND (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/13030/xtf0v19n4gf)
    '<H1>ERROR: ARK NOT FOUND</H1>'
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt')
    Traceback (most recent call last):
    ...
    AppError: Bad response: 400 ARK NOT FOUND (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt)
    '<H1>ERROR: ARK NOT FOUND</H1>'
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/13030/tf0v19n4gf')
    >>> res
    <200 OK text/plain body='<daoinfo>...nfo>'/259>
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/kt6199q402&parent_ark=ark:/13030/kt396nc6jn')
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/kt6199q402&parent_ark=ark:/13030/kt8j49q3pt')
    Traceback (most recent call last):
    ...
    AppError: Bad response: 400 ARK NOT FOUND (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/13030/kt6199q402&parent_ark=ark:/13030/kt8j49q3pt)
    '<H1>ERROR: ARK NOT FOUND</H1>'
    >>> res
    <200 OK text/plain body='<daoinfo>...nfo>'/389>
    '''
    status = '200 OK'
    output = 'Hello World!'

    form = cgi.parse_qs(environ['QUERY_STRING'])
    if not form.has_key("ark"): # and form.has_key("parent_ark")):
        status = '400 NO ARKS'
        output = '<h1>NO ARK PARAMETERS</h1>'
    else:
        #verify ark format, if not formatted correctly bug out
        ark = form["ark"][0]
        try:
            ark_parent = form["parent_ark"][0]
        except KeyError:
            ark_parent = None
        #TODO: use OAC ARK validator
        ark_valid = re.compile('ark:/\d+/\w+')
        ark_ok = True if ark_valid.search(ark) is not None else False
        ark_parent_ok = ark_valid.search(ark_parent) is not None if ark_parent else True
        if not ark_ok or not ark_parent_ok:
            status = '400 INCORRECT ARK FORMAT'
            output = "<H1>ERROR: INCORRECT ARK FORMAT</H1>"
        else:
            try:
                order, name_parent, ark_parent, url_parent, name_grandparent, ark_grandparent, url_grandparent, google_analytics_tracking_code = lookup_info(ark, ark_parent)
                if not name_grandparent:
                    name_grandparent = ''
                output = ''.join(["<daoinfo>",
                             "<order>", str(order), "</order>",
                             '<inst poi="', str(ark_parent), '" href="',
                             escape(url_parent) if url_parent else '','">',
                             escape(name_parent), "</inst>",
			     '<inst_parent poi="', str(ark_grandparent), '" href="',
                 escape(url_grandparent) if url_grandparent else '', '">',
                 escape(name_grandparent), "</inst_parent>",
                 '<google_analytics_tracking_code>', str(google_analytics_tracking_code), '</google_analytics_tracking_code>',
                             "</daoinfo>"
                             ]
                            )
            except KeyError:
                print >> sys.stderr, '+++++ ARK NOT FOUND IN OBJINFO DB : %s parent: %s' % (ark, ark_parent)
                status = '400 ARK NOT FOUND'
                output = "<H1>ERROR: ARK NOT FOUND</H1>"

    response_headers = [('Content-type', 'text/plain'),
                                    ('Content-Length', str(len(output)))]
    start_response(status, response_headers)
    return [output]

if __name__ == "__main__":
    import doctest
    doctest.testmod()
