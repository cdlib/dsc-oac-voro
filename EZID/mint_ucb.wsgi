import os, sys
import urlparse
import re
sys.path.append(os.path.abspath(os.path.dirname(__file__)))

import DSC_EZID_minter

SHOULDER_UCB_DSC = 'ark:/13030/k6'
SHOULDER_TEST = 'ark:/99999/fk4'

def application(environ, start_response):
    '''WSGI wrapper for the DSC_EZID_minter. This is currently only accesible
    from the local machine for security reasons.
    lives at /wsgi/mintark
    call with mint param: $BACK_SERVER/wsgi/minark?mint(<XXX>)
    '''
    status = '200 OK'
    output = ''

    shoulder = SHOULDER_UCB_DSC
    qs = urlparse.parse_qs(environ['QUERY_STRING'])
    match = re.match('play\((\d+)\)', environ['QUERY_STRING']) 
    if match:
        shoulder = SHOULDER_TEST
    else:
        match = re.match('mint\((\d+)\)', environ['QUERY_STRING']) 
    if not match:
        status = '400 NO MINT PARAM'
        output = '<h1>Missing number of arks to mint</h1>'
    else:
        try:
            num = int(match.group(1))
        except ValueError:
            status = '400 BAD MINT NUMBER'
            output = '<h1>Number parameter must be an integer</h1>'
        else:
            newarks = DSC_EZID_minter.main(num, shoulder=shoulder,
                    metadata = {'_profile':'dc', '_coowners': 'ucblibrary'})
            for ark in newarks:
                output = ''.join([output, ark[5:], '\n'])
    response_headers = [('Content-type', 'text/plain'),
                                    ('Content-Length', str(len(output)))]
    start_response(status, response_headers)
    return [output]
