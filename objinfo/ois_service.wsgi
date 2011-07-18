# Provides the ois (Object Info Service) cgi interface
# Input: ark of dao, finding aid ark (ark_parent)
# Returns: order of dao in parent
# name of parent institution
# name of grandparent institution
# google_analytics_tracking_code for parent institution

import sqlite3 as sqlite
import MySQLdb
import cgi
import re
from xml.sax.saxutils import escape
import os
from config_reader import read_config

HOME = os.environ['HOME']
DB_SQLITE = HOME + '/indexes/sqlite3/ois.sqlite3'
DB_SQLITE_TEST = './test/ois-test.sqlite3'

db = read_config()

DB_MYSQL_NAME = db['default-ro']['NAME']
DB_MYSQL_USER = db['default-ro']['USER']
DB_MYSQL_PASSWORD = db['default-ro']['PASSWORD']
DB_MYSQL_HOST = db['default-ro']['HOST']
DB_MYSQL_PORT = db['default-ro']['PORT']

def lookup_inst_names(ark_parent, ark_grandparent=None):
    '''For given ark, lookup the name in the Django DB
    '''
    conn = MySQLdb.connect(host=DB_MYSQL_HOST, user=DB_MYSQL_USER,
                           passwd=DB_MYSQL_PASSWORD, db=DB_MYSQL_NAME,
                           port=int(DB_MYSQL_PORT)
                          )
    c = conn.cursor()
    c.execute("""SELECT name from oac_institution where ark=%s""", (ark_parent,))
    name_parent = c.fetchone()
    if ark_grandparent:
        c.execute("""SELECT name from oac_institution where ark=%s""",
                  (ark_grandparent,))
        name_grandparent = c.fetchone()
    else:
        name_grandparent = (None,)

    conn.close()
    return name_parent[0], name_grandparent[0]

def lookup_info(ark, ark_parent, db=DB_SQLITE):
    '''Lookup item information in the ois.sqlite3 database.
    Returns the order of the object (for simple objs this is -1), name and ark
    of the contributing institution, name & ark of the parent institution if
    the contributing institution has a parent and 
    the google analytics tracking code for the owning institution.

    >>> x=lookup_info('ark:/13030/kt796nb207', db=DB_SQLITE_TEST)
    Traceback (most recent call last):
      File "<input>", line 1, in <module>
    TypeError: lookup_info() takes at least 2 non-keyword arguments (1 given)
    >>> x=lookup_info('ark:/13030/kt796nb207', None, db=DB_SQLITE_TEST)
    Traceback (most recent call last):
      File "<input>", line 1, in <module>
      File "ois_service.py", line 80, in lookup_info
        raise KeyError
    KeyError
    >>> x=lookup_info('ark:/13030/hb9j49p55', 'ark:/13030/kt0g5016h6', db=DB_SQLITE_TEST)
    >>> x
    (-1, 'Ethnic Studies Library', u'ark:/13030/kt4b69n6wx', 'UC Berkeley', u'ark:/13030/tf0p3009mq', u'')
    >>> x=lookup_info('ark:/13030/tf2c600703', 'ark:/13030/tf7s2010k4',  db=DB_SQLITE_TEST)
    >>> x
    (u'073', 'Bancroft Library', u'ark:/13030/tf7r29p8s0', 'UC Berkeley', u'ark:/13030/tf0p3009mq', u'')
    >>> x=lookup_info('ark:/13030/kt3199n606', None,  db=DB_SQLITE_TEST)
    Traceback (most recent call last):
      File "<input>", line 1, in <module>
      File "ois_service.py", line 80, in lookup_info
        raise KeyError
    KeyError
    >>> x=lookup_info('ark:/13030/kt5m3nb0t1', None, db=DB_SQLITE_TEST)
    >>> x
    (-1, 'Scripps Institution of Oceanography Archives', u'ark:/13030/tf22901027', 'Scripps Institution of Oceanography Archives', u'ark:/13030/tf22901027', u'')
    >>> x=lookup_info('ark:/13030/kt538nb0tr', None, db=DB_SQLITE_TEST)
    >>> x
    (-1, 'Scripps Institution of Oceanography Archives', u'ark:/13030/tf22901027', 'Scripps Institution of Oceanography Archives', u'ark:/13030/tf22901027', u'')
    >>> x=lookup_info('ark:/13030/kt787014q6', None, db=DB_SQLITE_TEST)
    >>> x
    (-1, 'Special Collections', u'ark:/13030/tf1489p250', 'Special Collections', u'ark:/13030/tf1489p250', u'')
    >>> x=lookup_info('ark:/13030/hb4k400701', None, db=DB_SQLITE_TEST)
    Traceback (most recent call last):
      File "<input>", line 1, in <module>
      File "ois_service.py", line 80, in lookup_info
        raise KeyError
    KeyError
    '''
    google_analytics_tracking_code = None
    num_order = -1
    if ark_parent:
       ark_object = ark
       ark_findingaid = ark_item = ark_parent
    else:
       ark_item = ark

    conn = sqlite.connect(db)
    c = conn.cursor()
    if ark_parent:
        #lookup digital object order
        c.execute('''SELECT num_order, google_analytics_tracking_code from digitalobject where ark=? and
                  ark_findingaid=?''', (ark_object, ark_findingaid)
                 )
        rowdata = c.fetchone()
        if rowdata:
            num_order, google_analytics_tracking_code = rowdata
    c.execute('''SELECT ark_parent, ark_grandparent, google_analytics_tracking_code from item where ark=?''', (ark_item, )
             )
    rowdata = c.fetchone()
    if not rowdata:
        raise KeyError
    ark_parent, ark_grandparent, g_a_code = rowdata
    if not google_analytics_tracking_code:
        google_analytics_tracking_code = g_a_code
    name_parent, name_grandparent = lookup_inst_names(ark_parent,
                                                      ark_grandparent)
    conn.close()
    return num_order, name_parent, ark_parent, name_grandparent, ark_grandparent, google_analytics_tracking_code

# WSGI interface here.
def application(environ, start_response):
    '''WSGI application for Object Info Service

    >>> from webtest import TestApp
    >>> from webob import Request, Response
    >>> app = TestApp(application)
    >>> res = app.get('/wsgi/ois_service/')
    Traceback (most recent call last):
      File "<input>", line 1, in <module>
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 156, in get
        expect_errors=expect_errors)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 389, in do_request
        self._check_status(status, res)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 424, in _check_status
        res.body))
    AppError: Bad response: 400 NO ARKS (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service/)
    <h1>NO ARK PARAMETERS</h1>
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=ark:/13030/tf0v19n4gf')
    Traceback (most recent call last):
      File "/dsc/local-builds/blake20110526/lib/python2.6/doctest.py", line 1253, in __run
        compileflags, 1) in test.globs
      File "<doctest __main__.application[3]>", line 1, in <module>
        res = app.get('/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=ark:/13030/tf0v19n4gf')
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 156, in get
        expect_errors=expect_errors)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 389, in do_request
        self._check_status(status, res)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 424, in _check_status
        res.body))
    AppError: Bad response: 400 INCORRECT ARK FORMAT (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=ark:/13030/tf0v19n4gf)
    <H1>ERROR: INCORRECT ARK FORMAT</H1>
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=')
    Traceback (most recent call last):
      File "/dsc/local-builds/blake20110526/lib/python2.6/doctest.py", line 1253, in __run
        compileflags, 1) in test.globs
      File "<doctest __main__.application[3]>", line 1, in <module>
        res = app.get('/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=')
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 156, in get
        expect_errors=expect_errors)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 389, in do_request
        self._check_status(status, res)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 424, in _check_status
        res.body))
    AppError: Bad response: 400 INCORRECT ARK FORMAT (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=)
    <H1>ERROR: INCORRECT ARK FORMAT</H1>
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/X3030/tf0v19n4gf')
    Traceback (most recent call last):
      File "/dsc/local-builds/blake20110526/lib/python2.6/doctest.py", line 1253, in __run
        compileflags, 1) in test.globs
      File "<doctest __main__.application[3]>", line 1, in <module>
        res = app.get('/wsgi/ois_service.wsgi?ark=ark:/XXXYYYYA3030/ft8t1nb2xt&parent_ark=ark:/13030/tf0v19n4gf')
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 156, in get
        expect_errors=expect_errors)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 389, in do_request
        self._check_status(status, res)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 424, in _check_status
        res.body))
    AppError: Bad response: 400 INCORRECT ARK FORMAT (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/X3030/tf0v19n4gf)
    <H1>ERROR: INCORRECT ARK FORMAT</H1>
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/13030/xtf0v19n4gf')
    Traceback (most recent call last):
      File "/dsc/local-builds/blake20110526/lib/python2.6/doctest.py", line 1253, in __run
        compileflags, 1) in test.globs
      File "<doctest __main__.application[4]>", line 1, in <module>
        res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/13030/xtf0v19n4gf')
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 156, in get
        expect_errors=expect_errors)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 389, in do_request
        self._check_status(status, res)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 424, in _check_status
        res.body))
    AppError: Bad response: 400 ARK NOT FOUND (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/13030/xtf0v19n4gf)
    <H1>ERROR: ARK NOT FOUND</H1>
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt')
    Traceback (most recent call last):
      File "/dsc/local-builds/blake20110526/lib/python2.6/doctest.py", line 1253, in __run
        compileflags, 1) in test.globs
      File "<doctest __main__.application[5]>", line 1, in <module>
        res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt')
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 156, in get
        expect_errors=expect_errors)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 389, in do_request
        self._check_status(status, res)
      File "/dsc/local-builds/blake20110526/lib/python2.6/site-packages/webtest/__init__.py", line 424, in _check_status
        res.body))
    AppError: Bad response: 400 ARK NOT FOUND (not 200 OK or 3xx redirect for http://localhost/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt)
    <H1>ERROR: ARK NOT FOUND</H1>
    >>> res = app.get('/wsgi/ois_service.wsgi?ark=ark:/13030/ft8t1nb2xt&parent_ark=ark:/13030/tf0v19n4gf')
    >>> res
    <200 OK text/plain body='<daoinfo>...nfo>'/263>
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
                order, name_parent, ark_parent, name_grandparent, ark_grandparent, google_analytics_tracking_code = lookup_info(ark, ark_parent)
                if not name_grandparent:
                    name_grandparent = ''
                output = ''.join(["<daoinfo>",
                             "<order>", str(order), "</order>",
                             '<inst poi="', str(ark_parent), '">', escape(name_parent), "</inst>",
			     '<inst_parent poi="', str(ark_grandparent), '">', escape(name_grandparent), "</inst_parent>",
                 '<google_analytics_tracking_code>', str(google_analytics_tracking_code), '</google_analytics_tracking_code>',
                             "</daoinfo>"
                             ]
                            )
            except KeyError:
                status = '400 ARK NOT FOUND'
                output = "<H1>ERROR: ARK NOT FOUND</H1>"

    response_headers = [('Content-type', 'text/plain'),
                                    ('Content-Length', str(len(output)))]
    start_response(status, response_headers)
    return [output]

if __name__ == "__main__":
    import doctest
    doctest.testmod()
