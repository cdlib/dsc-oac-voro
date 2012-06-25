2008/8/22 4pm MAR

(See the block of comments at the top of most of the scripts mentioned
below for more detailed information about them.)

For the 2007-2008 data:

Run:
	cd ../../contentdm/2007-2008
	./fetch.csh

	to pull the contentdm XML files that Adrian has put on Diva, into the 
	into that directory.  You'll first need to edit the file to change
	"obscured" to a valid Diva user and password in the "wget" commands.

Back in this directory....

Run "check_cdm.pl" to perform validity checking on a contentdm XML file.
	Run once for each contentdm XML file.  (See the "check.csh"
	file in "../../contentdm/2007-2008" for how I did it for the
	2007-2008 data.)

Run "run_7train.pl" to generate the METS XML:

	./run_7train.pl ../../contentdm/2007-2008 "" "" "" ../../mets/2007-2008

	Note that running this on "new" files (files that have local
	identifiers that have not been run through this process yet)
	will require additional ARK numbers be added to the BerkeleyDB
	file, so that they can be assigned to the new local identifiers.
	See "LHDRPassoc.java" for information about that.  To run
	"LHDRPassoc.java" at the command line, use "LHDRPassoc.run.csh".

Run "getMETS.pl" on the generated METS.  See "ingest.2007-2008.to.oac.csh".

Run "create.imgzoom.ingest.script.pl" to generate the script of "getTIFF.pl"
	commands necessary to ingest the TIFF files into our "imgzoom"
	system.  Before running that command, create a file that contains
	the list of URLs where the TIFF files are located.  The script
	reads that file, and uses the string to the right of the rightmost
	slash as a "key" to determine the entire URL.  See 
	"lhdrp.2007-2008.tiffs.txt".

	Look at the output file.  If you didn't specify the URL list file,
	you'll need to edit each line, to specify the location of the TIFF
	file.

	Copy the output file to "imgzoom.cdlib.org", and run it there, as
	user "imgzoom".

Run "generate.DPR.lists.pl" to create the files that can then be passed
	to Mark Reyes, which he can use to ingest the METS and image files
	into DPR.

2009/5/15 4:30pm MAR

We are beginning to process non-LHDRP contentdm exports.  We had the same
need to translate local identifiers to ARK numbers, but we didn't want the
universe of LHDRP local identifiers to overlap the universe of non-LHDRP
local identifiers.  I changed "LHDRPassoc.java" so that it picked up the
BerkeleyDB key prefix for the local identifier from the properties file.
The key prefix is what we'll use to keep the two universes separate.
There are now two properties files, one for LHDRP processing and one for
non-LHDRP processing.  Since the properties files are folded into JAR
files, there are two JAR files too (with the only difference that one
contains the LHDRP properties file, and the other contains the non-LHDRP
properties file).
