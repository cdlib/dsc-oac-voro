import urlparse
import os, sys
sys.path.append(os.path.abspath(os.path.dirname(__file__)))

import DSC_EZID_minter

def application(environ, start_response):
    '''WSGI wrapper for the DSC_EZID_minter. This is currently only accesible
    from the local machine for security reasons.
    lives at /wsgi/mintark
    call with number param: $BACK_SERVER/wsgi/minark?number=<XXX>
    '''
    status = '200 OK'
    output = ''

    qs = urlparse.parse_qs(environ['QUERY_STRING'])
    shoulder = None
    if qs.has_key('shoulder'):
        shoulder = qs['shoulder'][0]
    if not qs.has_key('number'): 
        status = '400 NO NUMBER'
        output = '<h1>Missing number of arks to mint</h1>'
    else:
        try:
            num = int(qs['number'][0])
        except ValueError:
            status = '400 BAD NUMBER'
            output = '<h1>Number parameter must be an integer</h1>'
        else:
            if num <= 10:
                newarks = DSC_EZID_minter.main(num, shoulder=shoulder)
                for ark in newarks:
                    output = ''.join([output, ark, '\n'])
            else:
                status = '400 TOO MANY ARKS REQUESTED NUMBER'
                output = '<h1>Can only request 10 ARKs at a time from this interface</h1>'
    response_headers = [('Content-type', 'text/plain'),
                                    ('Content-Length', str(len(output)))]
    start_response(status, response_headers)
    return [output]
