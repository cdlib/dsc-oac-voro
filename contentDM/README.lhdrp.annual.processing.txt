2009/8/6 2:30pm MAR

NOTE:	There are two different CVS repositories in use here.  One is the
	CDL CVS repository, and the other is the Voro data CVS repository.
	The former was, at the time of this writing, on a different machine
	than "voro.cdlib.org", whereas the latter was on the same machine.
	Accessing the two repositories is different.  The CDL CVS repository
	needs to be accessed using environment variables:
		"CVS_RSH" set to "ssh"
		"CVSROOT" set to ":ext:YOURACCOUNT@cvs.cdlib.org:/cvs/root"
	and it may be necessary to specify "-d" on the "cvs" command
	(for example, "cvs -d :ext:YOURACCOUNT@cvs.cdlib.org:/cvs/root ....").
	To access the Voro data CVS repository, leave the two above-mentioned
	environment variables unset, and do not include the "-d" parameter
	on the "cvs" command.

	The contentdm and METS XML files are kept in the Voro data CVS
	repository, and everything else is kept in the CDL CVS repository.

The annual processing of the LHDRP data consists of the follow steps.

(1)	Step overview:  incorporate the data about the new contributors
	into the infrastructure.
	-----
	Receive information from the data analyst about the contributors.
	The information for each contibutor is:
		1.  the institution's name
		2.  the institution's MARC code
		3.  the institution's ARK number
		4.  the institution's URL
		5.  the EAD's ARK number
		6.  the EAD's title

	Place these values as atttributes of an "<institution>" element
	in file "dsc.cdlib.org:/apps/dsc/branches/production/voro/contentDM/7train/institutions.xml".

	Here is an example:

	<institution name="Upland Public Library" marccode="cupl"
		ark="ark:/13030/kt5j49s0m9"
		url="http://www.uplandpl.lib.ca.us/" eadark="kt6r29r1w3"
		eadlabel="Upland Public Library Historic Photograph Collection"/>

	This presumes that the data analyst has already added the
	institution as an OAC contributor (in order to get its ARK
	number assigned), and has already ingested the EAD finding aid
	(to get its ARK number assigned).  Note that the format of the
	institution's ARK number is different from the format of the
	EAD's ARK number.  Only the rightmost component of the latter is
	specified.

	Commit this file to hg once it has been updated.

(2)	Step overview:  put the new contentdm export files in the file
	system.
	-----
	Receive a set of contentdm export files from the data analyst.
	Generally, there will be one for each institution.  It's OK if
	there are objects associated with more than one EAD finding aid
	in one contentdm export file.  (Which EAD an object is associated
	with, is determined by the text content of its "<isPartOf>"
	element, and that need not be the same for all objects in one
	file.)

	Create a subdirectory of "dsc.cdlib.org:/apps/dsc/data/oac-lsta/contentdm"
	consisting of the year of the project.  For example:

	mkdir /apps/dsc/data/oac-lsta/contentdm/2008-2009

TODO:	Add this directory to CVS (Voro data CVS repository).

	Put the contentdm files in the new directory, and add and commit
	them to CVS (Voro data CVS repository).

(3)	Step overview:  get enough new ARK numbers for the new contentdm
	objects, and add them into the infrastructure.
	-----
	Determine the count of new METS objects that will be created.
	One way to do that is to count the number of "<record>" elements
	in the contentdm files.  For example:

	% cd /apps/dsc/data/oac-lsta/contentdm/2008-2009
	% grep '<record>' *.xml | wc -l
	    1823

	Get that many new ARK numbers, which will be assigned to the
	METS objects that will be created below.  Add the new ARK
	numbers to the "LHDRP Association" database.  If the new
	ARK numbers are in file "/abc/def/ghi", then the command to
	add them to the database is:

	% /bin/cat /abc/def/ghi | xargs ./code/LHDRPassoc.run.bash unassigned

	Once this step is done, it should not need to be re-done until
	the following year, unless one of the updates of the contentdm
	files involves increasing the count of objects in the file, in
	which case it will be necessary to add a number of new ARK
	numbers equal to the count of additional objects in the file.

(4)	Step overview:  verify the checksums of the image files.
	-----
	When we get the image files, they typically include a set of
	files that contain the checksums of the image files.  Copy script
	-rwxrwxr-x   1 voro     voro        6996 Aug 11  2008 /apps/dsc/branches/production/voro/contentDM/code/checksum.checker.pl
	to the machine on which the image files are located.  (This may
	include changing the contents of the first line of the script,
	which hard-codes the location of the Perl binary.)  Run the
	command, to check the checksums.  This can take some time because
	the image files can be quite large.  (For 2008-2009, the size of
	the directory is 62 Gbytes.  That's a lot of data to pull through
	a USB port.)  For example:
		% ./checksum.checker.pl /media/Califa2006-7/2008_2009
		checksum.checker.pl:  ignoring "/media/Califa2006-7/2008_2009/checksum.fil" because it is not a directory
		checksum.checker.pl:  ignoring "/media/Califa2006-7/2008_2009/contents.txt" because it is not a directory
		checksum.checker.pl:  7772 checksums checked

(5)	Step overview:  generate a list of the image files.
	-----
	Get a list of the image files that we have.  This amounts to
	"cd"ing to the directory that contains the year's image files,
	and running a "find" command, to list the output.  For 2008-2009,
	the top level directory of the disk contained these directories:
		drwxrwxrwx 1 root root 4096 2008-05-29 12:32 2006_2007
		drwxrwxrwx 1 root root 4096 2008-05-30 11:17 2007_2008
		drwxrwxrwx 1 root root 4096 2009-05-18 06:09 2008_2009
		drwxrwxrwx 1 root root    0 2008-05-29 12:34 RECYCLER
		drwxrwxrwx 1 root root 4096 2009-05-14 08:53 System Volume Information
	We want the "/2008_2009" directory.  In it are:
		drwxrwxrwx 1 root root      0 2009-05-15 04:40 cajuol
		drwxrwxrwx 1 root root      0 2009-05-15 04:54 ccoron
		drwxrwxrwx 1 root root      0 2009-05-15 04:57 ccr
		drwxrwxrwx 1 root root      0 2009-05-15 05:00 cesc
		-rwxrwxrwx 1 root root     64 2009-05-18 06:09 checksum.fil
		-rwxrwxrwx 1 root root 305127 2009-05-18 06:09 contents.txt
		drwxrwxrwx 1 root root      0 2009-05-15 05:04 cssf
		drwxrwxrwx 1 root root      0 2009-05-15 05:09 cupl
		drwxrwxrwx 1 root root      0 2009-05-15 05:14 gtu
		drwxrwxrwx 1 root root      0 2009-05-15 05:18 mills
		drwxrwxrwx 1 root root      0 2009-05-15 05:20 sdsu
		drwxrwxrwx 1 root root      0 2009-05-15 05:26 ucr
	The disk happened to be mounted at mount point "/media/Califa2006-7".
	So, the commands we want are:
		% cd /media/Califa2006-7/2008_2009
		% find . -type f -print > list.of.2008.2009.files.txt
	(It so happens that there are a couple of files file in that
	directory that the script will complain about, because it won't
	recognize them.  They are "/contents.txt" and "/checksum.fil".  You
	can either ignore the messages about them when	you run the script,
	or you can filter out the files now.  To do the latter, change the
	"find" command to:
		% find . -type f -print | grep -v '^\.\/contents.txt$' | \
		? grep -v '^\.\/checksum.fil$' > list.of.2008.2009.files.txt
	.)  Move the file that contains the list of image files to
	"voro.cdlib.org", so that it can be accessed by the "check_cdm.pl"		script.

(6)	Step overview:  do a sanity check on the contentdm export files.
	-----
	The command to do that is "check_cdm.pl".  See the files
	/voro/data/oac-lsta/contentdm/2007-2008/check.csh
	/voro/data/oac-lsta/contentdm/2008-2009/check.csh
	for examples of how I did this in the past.

	If there are no errors, proceed to the next step.  If there are
	errors, notify the data analyst, requesting that they be fixed,
	wait for the replacement file or files, overwrite the bad file
	or files that were installed in step (2) with the replacement file
	or files, commit them to CVS (Voro data CVS repository), and
	rerun this step.

    NOTE:(MER) -- We now get the images from Luna Imaging and they have
    a different format for the image files. There also appears to be a
    disconnect from the content dm export to the file names on disk for the 
    2011-2012 batch. check_cdm.pl is very picky about the format of the 
    directory names to the image files. I'm going to make a modified script 
    to deal with the luna directory structure.
    NOTE: THIS SCRIPT JUST DOESN"T WORK WITH THE NEW DIRECTORY STRUCTURE,
    makes a lot of assumptions about file paths and such.

    MER- i didn't run this for 2011-2012


(6.5)	Step overview:  make sure that the 7train stylesheet "cdm.xsl" is
	generating the correct URL for the TIFF images.
	----
	In directory "/apps/dsc/branches/production/voro/contentDM/7train", look at file "cdm.xsl".
	In CVS version 1.7 of that file, note that the string "ingest1"
	appears in 3 places.  Those are the places to change.  To the end
	of the URL that shows on those lines, the stylesheet will append
	the institution code, "/tiff/", and the TIFF file name.  For the
	2008-2009 processing, we plugged the USB disk into my PC.  My
	PC doesn't have a domain name, so I had to use its IP address in
	the URLs ("http://128.48.204.141").  I made the Northern Micrographics
	disk available at "http://128.48.204.141/lhdrp", via this symbolic link:

	lrwxrwxrwx 1 root root 19 2009-08-12 13:08 /var/www/lhdrp -> /media/Califa2006-7

	and with the Northern Micrographics mounted where it was when I
	plugged it in:

	Filesystem            Size  Used Avail Use% Mounted on
	/dev/sdc1             233G  179G   55G  77% /media/Califa2006-7

	The subdirectory that contained the 2008-2009 images was "2008_2009",
	so the URL became "http://128.48.204.141/lhdrp/2008_2009/", and that's
	what appears in "cdm.xsl" for CVS version 1.8.

(7a)    Step overview: Rewrite the contentdm image URLs
        -----
        As of 2011, the contentdm is setup a bit differently and now it
        exposes jpeg 2000 files for the access images. This requires
        rewriting the image file URLs as exported by contentdm.
        NOTE: 2011-2012 doesn't need this
	To do, run /apps/dsc/branches/production/voro/contentDM/code/preprocess_jp2.py on 
	each xml export file.
	% /apps/dsc/branches/production/voro/contentDM/code/preprocess_jp2.py \
	/voro/data/oac-lsta/contentdm/2010-2011/csumbl.xml

	See /voro/data/oac-lsta/contentdm/2010-2011/run_jp2.csh for an 
	example script.

(7)	Step overview:  create METS files from the contentdm export files.
	-----
	Once "check_cdm.pl" produces clean output for all of the contentdm
	export files, run 7train on them to create the METS files for
	the objects.

	Create a subdirectory of "/apps/dsc/data/oac-lsta/mets" by the same name
	as the subdirectory of "/apps/dsc/data/oac-lsta/contentdm" that was
	created in step (2).  Add this new directory to CVS (Voro data
	CVS repository).
	
	Run 7train using the newly created subdirectory as its output
	location.  For example,

	% /apps/dsc/branches/production/voro/contentDM/code/run_7train.pl \
	? /apps/dsc/data/in/oac-lsta/contentdm/2008-2009 \
	? "" "" "" /apps/dsc/data/in/oac-lsta/mets/2008-2009

	The METS will be created in the directory specified as the fifth
	command line parameter to the "run_7train.pl" command (which was
	"/apps/dsc/data/oac-lsta/mets/2008-2009" in the above example).

	Add and commit the new METS XML files (Voro data CVS repository).

(7b - 2011-2012) -- Needed to move the files to match the generated paths from
7Train. Essentially this is flattening out the structure to the <inst
code>/(tiff|jpeg/<files>. Need to find all of <inst code> dirs on the LUNa
drive and copy them to ~/Sites/luna-img/<inst code>/(tiff|jpeg)/<file>

(8)	Step overview:  ingest the new METS into production.
	-----
	Run "getMETS.pl" on the new METS XML files.  Someone should tell you
	whether to ingest the new METS XML files on staging or on production
	(in which case, you run the "getMETS.pl" command on staging or
	production, respectively).  If you haven't been told on which
	system to ingest the new METS XML files, ask.

	If the METS are in a subdirectory of "/apps/dsc/data/in/oac-lsta/mets",
	then they are already accessible from the web.  To create the URL
	in that case, substitute
	"http://voro.cdlib.org/oac-lsta/mets" for
	"/apps/dsc/data/in/oac-lsta/mets" in the fully qualified file name of the
	METS file.  Use that as a parameter for the
	"/voro/code/batch-bin/getMETS.pl" comamnd.

	See files
	"/apps/dsc/branches/production/voro/contentDM/code/scripts/ingest.2007-2008.to.oac.csh" and
	"/apps/dsc/branches/production/voro/contentDM/code/scripts/ingest.2008-2009.to.oac.csh"
	for examples of this processing.

	The "getMETS.pl" command sometimes prints error messages even
	though the ingest of the object is successful.  So, you may
	ignore error messages from the "getMETS.pl" command prints.

	When the next reindex has completed, the objects will be accessible
	on the site.

	There are typically things that need to be changed about the
	objects.  So, it may be necessary to repeat steps (2), (6), (7),
	and (8) until the data analyst says everything is OK.

(9)	Step overview:  ingest the TIFF images into the "imgzoom" web site.
	-----
	These are included on the hard disk drive which is snail mailed to
	us, the list of the contents of which you created in step (5).
	Make the contents of the disk available on the web somehow.

	(The disk has been in a USB enclosure, and I have been plugging
	it into a USB port on my Linux PC, and making it available via
	the Apache server that is running there.  But, there have been
	times when the contents of the disk was copied onto a CDL
	desktop system, a CDL development server, or a CDL staging
	server.)

	Create a file that contiains a list of URLs of the TIFF files,
	with one URL per line.  For the 2008-2009 data, the disk came online
	as "/media/Califa2006-7" when I plugged it into my PC.  I added a
	symlink "/var/www/lhdrp -> /media/Califa2006-7", which made the
	disk web-accessible as "http://128.48.204.141/lhdrp".  The 2008-2009
	files were in the "2008_2009" subdirectory.  So, I ran this command
	on my PC to generate the list of URLs:

	% find /media/Califa2006-7/2008_2009 -type f -print | grep -v \
	? 'checksum.fil$' | sed \
	? 's/^\/media\/Califa2006-7/http:\/\/128.48.204.141\/lhdrp/' > \
	? urls-for-2008-2009.txt

	Then I copied the resulting file ("urls-for-2008-2009.txt") to
	"voro.cdlib.org" in order to be able to use it as an input file
	to the "create.imgzoom.ingest.script.pl" command, shown below.

	Run the "create.imgzoom.ingest.script.pl" script using the METS
	directory and the URL file as input.  For example:

	% /apps/dsc/branches/production/voro/contentDM/code/create.imgzoom.ingest.script.pl \
	? /apps/dsc/data/oac-lsta/mets/2008-2009 gettiff.script.pl \
	? urls-for-2008-2009.txt 

	In this example, "urls-for-2008-2009.txt" is the file that contains
	the URLs, and "gettiff.script.pl" is the output file.  It is a
	set of "getTIFF.pl" commands.  On "imgzoom.cdlib.org", the "getTIFF.pl"
	command is in the "/imgzoom/ingest/bin" directory.

	Edit the "gettiff.script.pl" to make the command name a fully qualified
	file name.  The "vi" command to do this is:

		:%s/^/\/imgzoom\/ingest\/bin\//
        <xsl:call-template name="insert-good-institution-name-orig"/>

    (****NOTE*****: you can also edit the gettiff.script.pl to make it just the input
    file for getTIFF.pl on imgzoom. Remove the "getTIFF.pl " at the start of
    each line and remove any single quotes from the file. The new file can
    become the input for getTIFF.pl on imagzoom.)

	Copy the output file to "imgzoom.cdlib.org", probably using "sftp",
	and run it there as user "imgzoom".

	(A piece of information that you don't need to know, but may help
	you understand things:  "getTIFF.pl" fetches the TIFF file, and
	converts it to a JPEG2000 [which is not the same as JPEG], and
	then discards the TIFF.)

(9.5)	Step overview:  make "dsc.cdlib.org" aware of everything that's on
	"imgzoom.cdlib.org".
	-----
	On "imgzoom.cdlib.org", run the command
	"/imgzoom/ingest/bin/buildDone.pl" as user "imgzoom".

	Then on "dsc.cdlib.org", run command
	"/dsc/data/jp2shadow/REFRESH.sh" as user "dsc".

	After the next XTF index, the links to "imgzoom.cdlib.org" will be
	present on the newly added images.

(10)	Step overview:  ingest the METS files into DPR.
	----
	Run the "generate.DPR.lists.pl" command.

	For example:

	("cd" into pretty much any directory.  It might make most sense
	to "cd /voro/data/oac-lsta", but it really doesn't make any
	difference.  In the past, this directory has been temporary.
	That is, I delete it when I have passed the files to Mark
	Reyes.  So, the directory *CAN* be temporary, but it shouldn't
	hurt to leave it around.  I would advise deleting last year's
	directory before running the command for the current year,
	because the file names within the directory will be the same.
	If the script creates fewer files this year than last year,
	and you use the same directory as last year, then some files
	from last year will remain in the directory.  If you send all
	the files in the directory to Mark, there may be some confusion.)

	% mkdir DPR.files
	% /apps/dsc/branches/production/voro/contentDM/code/generate.DPR.lists.pl \
	? 2008-2009 DPR.files

	In this example, "2008-2009" is appended to the value of command
	line parameter 3 (the default of which is "/apps/dsc/data/oac-lsta/mets")
	to create the input directory), and the files needed by DPR
	personnel (typically Mark Reyes) are written in directory "DPR.files".
	Provide the files to DPR personnel.
