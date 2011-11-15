#! /usr/bin/env python
'''
Use an extf search in the raw and parse out the docHit IDs for the various
objects. Stream the ids to stdout and save in file, then add the appropriate parent id to the resulting file.
'''
import xml.etree.ElementTree as ET
import requests #easier http

url = 'http://voro-s10.cdlib.org/xtf/search?docsPerPage=400&facet=type-tab&group=&type=&publisher=Oroville+Chinese+Temple&publisher-join=&relation=ark%3A%2F13030%2Fkt5p3019m2&relation-join=&sortDocsBy=&style=cui&brand=calisphere&x=12&y=12&raw=1' # oroville chinese temple docs

url = 'http://voro-s10.cdlib.org/xtf/search?docsPerPage=400&facet=type-tab&group=&type=&publisher=Ethnic+Studies&publisher-join=&relation=ark%3A%2F13030%2Fkt5p3019m2&relation-join=&sortDocsBy=&style=cui&brand=calisphere&x=12&y=12&raw=1' # Ethnic Studies images

url = 'http://voro-s10.cdlib.org/xtf/search?docsPerPage=400&facet=type-tab&publisher=Ethnic%20Studies&relation=ark:/13030/kt5p3019m2&brand=calisphere&x=12&y=12&style=cui&group=text&raw=1' #ethnic studies texts

url = 'http://voro-s10.cdlib.org/xtf/search?docsPerPage=800&facet=type-tab&publisher=Historical+Society&relation=ark:/13030/kt5p3019m2&brand=calisphere&x=12&y=12&&style=cui&group=image&raw=1' # cal hist society images

url = 'http://voro-s10.cdlib.org/xtf/search?docsPerPage=100&facet=type-tab&publisher=Historical%20Society&relation=ark:/13030/kt5p3019m2&brand=calisphere&x=12&y=12&&style=cui&group=text&raw=1' # cal hist texts

resp = requests.get(url)

tree= ET.fromstring(resp.content)
docHits = tree.findall('facet/group/docHit')

for docHit in docHits:
    ident = docHit.find('meta/identifier')
    print 'ark:' + ident.text.split('ark:')[1]
