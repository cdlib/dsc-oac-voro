#! /bin/csh

# ------------------------------------
#
# Project:	LSTA LHDRP
#
# Name:		LHDRPassoc.run.csh
#
# Function:	To run the "LHDRPassoc" Java program from the command line.
#
# Command line parameters:  all are passed to the Java program.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2008/7/10 - MAR - Initial writing
#
# ------------------------------------

set dir = /apps/dac/branches/production/voro/contentDM/code

java -cp $dir/classes/LHDRPassoc.jar:$dir/classes/je-3.2.76/lib/je-3.2.76.jar org.cdlib.dsc.util.LHDRPassoc $*

exit $status
