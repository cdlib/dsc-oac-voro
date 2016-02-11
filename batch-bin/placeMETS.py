#!/usr/bin/env python
# -*- coding: utf-8 -*-
""" facet decade in python """

import sys
import argparse
import re
import os
from lxml import etree
from shutil import copy2  # sort of like `cp -p`


def is_xml_file(parser, arg):
    xmlns = {'mets': 'http://www.loc.gov/METS/'}
    try:
        return (
            arg,
            etree.parse(arg).xpath('/mets:mets/@OBJID', namespaces=xmlns)[0]
        )
    except IOError:
        parser.error("{0} does not exist".format(arg))
    except etree.XMLSyntaxError as e:
        parser.error("{0} XMLSyntaxError {1}".format(arg, e))
    except IndexError:
        parser.error(
            "{0} /{{http://www.loc.gov/METS/}}mets/@OBJID not found"
            .format(arg)
        )


def ark_to_path(string):
    os.environ['XTF_DATA']
    parsed_ark = re.search('ark:/(\d{5})/(\w*)', string)
    naan = parsed_ark.group(1)
    part = parsed_ark.group(2)
    sdir = part[-2:]
    return os.path.join(
        os.environ['XTF_DATA'],
        naan,
        sdir,
        part,
        '{0}.mets.xml'.format(part)
    )


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'mets_document',
        nargs="+",
        type=lambda x: is_xml_file(parser, x)
    )

    if argv is None:
        argv = parser.parse_args()

    for ark in argv.mets_document:
        copy2(ark[0], ark_to_path(ark[1]))


# main() idiom for importing into REPL for debugging
if __name__ == "__main__":
    sys.exit(main())


"""
Copyright © 2015, Regents of the University of California
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
- Neither the name of the University of California nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
"""
