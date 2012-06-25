#! /bin/csh

# ------------------------------------
#
# Project:	contentdm processing (LHDRP and non-LHDRP)
#
# Name:		LHDRPassoc.build.jar.csh
#
# Function:	To compile the nearby "LHDRPassoc.java" source file, and
#		prepare the ".jar" file for it.
#
# Command line parameters:  none.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2008/7/10 - MAR - Initial writing
#		2009/5/15 - MAR - Add the creation of a version of the
#			JAR file to be used for non-LHDRP processing
#
# ------------------------------------

set dir = /apps/dsc/branches/production/voro/contentDM/code

cd $dir
javac -classpath classes/je-3.2.76/lib/je-3.2.76.jar LHDRPassoc.java

# Stop if the compile didn't go OK.
if ($status != 0) exit $status

# Create the directory structure we'll need for the LHDRP "jar" file.
/bin/rm -rf org
mkdir org org/cdlib org/cdlib/dsc org/cdlib/dsc/util
cp LHDRPassoc.class org/cdlib/dsc/util
cp LHDRPassoc.properties org/cdlib/dsc/util

# Create the LHDRP "jar" file.
jar cf classes/LHDRPassoc.jar org

# Create the directory structure we'll need for the non-LHDRP "jar" file.
/bin/rm -rf org
mkdir org org/cdlib org/cdlib/dsc org/cdlib/dsc/util
mv LHDRPassoc.class org/cdlib/dsc/util
cp nonLHDRPassoc.properties org/cdlib/dsc/util/LHDRPassoc.properties

# Create the non-LHDRP "jar" file.
jar cf classes/nonLHDRPassoc.jar org

# Clean up.
/bin/rm -rf org
