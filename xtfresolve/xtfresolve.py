from lxml import etree
import os
import cgi
import re
from xml.sax.saxutils import escape

def poi2file(poi):
    '''Take a METS POI and translate to a filepath
    TODO: BETTER ERROR CHECKING?
    
    >>> poi2file('ark:/13030/hb2g5004x8')
    '/dsc/data/xtf/data/13030/x8/hb2g5004x8/hb2g5004x8'
    '''
    poi = poi.replace('/','')
    poi = poi.replace('.','')
    dir = poi[-2:]
    #$poi =~ s|ark:(\d\d\d\d\d)(.*)|/texts/data/$1/$dir/$2/$2|;
    #TODO: make poi parse smarter
    result = re.match('ark:(\d\d\d\d\d)(.*)', poi)
    fpath = ''.join(('/dsc/data/xtf/data/', result.group(1), '/', dir, '/',
                    result.group(2), '/', result.group(2), ))
    return fpath

def report_error(resp, stat, msg):
    response_headers = [('Content-type', 'text/plain'),
                                    ('Content-Length', str(len(msg)))]
    resp(stat, response_headers)
    return [msg]

# WSGI interface here.
def application(environ, start_response):
    '''Resolvers for METS files

    >>> environ = {}
    >>> def start_response(status, headers):
    ...   print status
    ...   print headers
    ... 
    >>> application(environ, start_response)
    400 BAD REQUEST
    [('Content-type', 'text/plain'), ('Content-Length', '24')]
    ['<h1>NO Query String</h1>']
    >>> environ = {'QUERY_STRING':''}
    >>> application(environ, start_response)
    400 BAD REQUEST
    [('Content-type', 'text/plain'), ('Content-Length', '30')]
    ['<h1>NO POI Query paramter</h1>']
    >>> environ = {'QUERY_STRING':'POI=ark:/13030/hb2g5004x8&POI=FID5'}
    >>> application(environ, start_response)
    400 BAD REQUEST
    [('Content-type', 'text/plain'), ('Content-Length', '57')]
    ['<h1>More than one  POI Query paramter is not allowed</h1>']
    >>> environ = {'QUERY_STRING':'POI=ark:/13030/hb2g5004x8'}
    >>> application(environ, start_response)
    400 BAD REQUEST
    [('Content-type', 'text/plain'), ('Content-Length', '33')]
    ['<h1>NO fileID Query paramter</h1>']
    >>> environ = {'QUERY_STRING':'POI=ark:/13030/hb2g5004x8&fileID=FID5',}
    >>> application(environ, start_response)
    302 Found
    [('Location', 'http://cdn-dev.calisphere.org/dynaxml/data/13030/x8/hb2g5004x8/files/hb2g5004x8-FID5.jpg'), ('Content-type', 'text/plain'), ('Content-Length', '88')]
    ['http://cdn-dev.calisphere.org/dynaxml/data/13030/x8/hb2g5004x8/files/hb2g5004x8-FID5.jpg']
    '''

    status = '200 OK'
    output = 'Hello World!'
    response_headers = [('Content-type', 'text/plain'),
                                    ('Content-Length', str(len(output)))]

    if not environ.has_key('QUERY_STRING'):
        status = '400 BAD REQUEST'
        output = '<h1>NO Query String</h1>'
        return report_error(start_response, status, output)
    qs = cgi.parse_qs(environ['QUERY_STRING'])
    if not qs.has_key('POI'):
        status = '400 BAD REQUEST'
        output = '<h1>NO POI Query paramter</h1>'
        return report_error(start_response, status, output)
    if len(qs['POI']) != 1:
        status = '400 BAD REQUEST'
        output = '<h1>More than one  POI Query paramter is not allowed</h1>'
        return report_error(start_response, status, output)
    if not qs.has_key('fileID'):
        status = '400 BAD REQUEST'
        output = '<h1>NO fileID Query paramter</h1>'
        return report_error(start_response, status, output)
    fileID_raw = qs['fileID'][0]
    fileID, ext = os.path.splitext(fileID_raw)
    if ext not in ('.jpg', '.jpeg', '.gif'):
        fileID = fileID_raw
    fname = ''.join((poi2file(qs['POI'][0]), '.mets.xml'))
    try: 
    	foo = open(fname)
    except IOError, e:
        status = '404 NOT FOUND'
        output = '<h1>No file found for poi</h1>'
        return report_error(start_response, status, output)
    doc = etree.parse(foo)
    xpath = ''.join(('(/m:mets/m:fileSec//m:file[@ID="', fileID,
                     '"])[1]/m:FLocat[1]/@*[local-name() = \'href\']'))
    #print "XPATH: ", xpath
    namespaces = { 'm': 'http://www.loc.gov/METS/',
                   'xlink': 'http://www.w3.org/TR/xlink'}
    node = doc.xpath(xpath, namespaces=namespaces)  
    if not len(node):
        if fileID_raw.lower() == 'thumbnail':
            fileurl = 'http://www.calisphere.universityofcalifornia.edu/images/misc/no_image1.gif'
        else:
            #original redirected to / param POI ???
            #security flaw here?
            #fileurl = 'http://content.cdlib.org/'+qs['POI'][0]
            status = '404 NOT FOUND'
            output = '<h1>NO mets fileSec found</h1>'
            return report_error(start_response, status, output)
    else:
        # what to do if node list len > 1?
        fileurl = re.sub('\s', '+', node[0])
        # replace host with CDN_BEAR_FOR
        fileurl = re.sub(r'http://.+\.cdlib\.org/', ''.join(('https://', os.environ['CDN_BEAR_FOR'], '/')), fileurl)
        if fileurl.startswith('http://www.bampfa.berkeley.edu'):
            fileurl = re.sub(r'^http://www', 'http://archive', fileurl)
        if fileurl.startswith('http://sunsite.berkeley.edu'):
            fileurl = re.sub(r'http://sunsite.berkeley.edu', 'https://cdn.calisphere.org/affiliates/images/sunsite.berkeley.edu', fileurl)
        if fileurl.startswith('http://www.janm.org'):
            fileurl = re.sub(r'http://www.janm.org', 'https://cdn.calisphere.org/affiliates/images/www.janm.org', fileurl)

    output = fileurl
    status = '302 Found'
    response_headers = [('Location', fileurl),
                        ('Content-type', 'text/plain'),
                        ('Content-Length', str(len(output)))]
    start_response(status, response_headers)
    return [output]

if __name__=="__main__":
    print "SELF TEST"
    import doctest
    doctest.testmod()
