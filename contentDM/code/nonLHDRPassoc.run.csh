#! /bin/csh

# ------------------------------------
#
# Project:	non-LHDRP contentdm processing
#
# Name:		nonLHDRPassoc.run.csh
#
# Function:	To run the "LHDRPassoc" Java program from the command line
#		with the non-LHDRP key prefix
#
# Command line parameters:  all are passed to the Java program.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2009/5/15 - MAR - Initial writing (cloned from
#			"LHDRPassoc.run.csh")
#
# ------------------------------------

set dir = /voro/data/oac-lsta/admin/code

java -cp $dir/classes/nonLHDRPassoc.jar:$dir/classes/je-3.2.76/lib/je-3.2.76.jar org.cdlib.dsc.util.LHDRPassoc $*

exit $status
