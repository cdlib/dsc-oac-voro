2009/5/15 3:45pm MAR
revised 2009/8/14 12:45pm MAR

NOTE:   There are two different CVS repositories in use here.  One is the
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

NOTE:	Consider keeping a transcript of the work done on the contentdm
	export file, especially if additional things that are not documented
	here need to be done to the contentdm export file.  To see examples
	of what's already been done alone these lines see files:
	"/apps/dsc/data/oac-lsta/non-lhdrp/README.ccber.txt",
	"/apps/dsc/data/oac-lsta/non-lhdrp/README.muir.1.txt", and
	"/apps/dsc/data/oac-lsta/non-lhdrp/README.SCJARexport2_jpg_only.1.txt".

	If you do keep a transcript, commit it to CVS (CDL CVS repository).

We are going to be processing non-LHDRP contentdm exports.  This
directory holds the files needed to do that.  These are the steps.

(1)	Step overview:  incorporate the data about the new contributor into
	the infrastructure.
	-----
	Receive information from the data analyst about the contributor.
	That information is:
		1.  the institution's name
		2.  the institution's MARC code
		3.  the institution's ARK number
		4.  the institution's URL
		5.  the EAD's ARK number
		6.  the EAD's title

	Place these values as atttributes of an "<institution>" element
	in file
	"voro.cdlib.org:/apps/dsc/data/oac-lsta/non-lhdrp/7train/institutions.xml".

	Here is an example:

	<institution
		name="Occidental College Library"
		marccode="clo"
		ark="ark:/13030/kt4p3021tf"
		eadark="kt638nc9ww"
		eadlabel="Japanese American Relocation Collection"
		Url="http://departments.oxy.edu/library/"/>

	This presumes that the data analyst has already added the
	institution as an OAC contributor (in order to get its ARK
	number assigned), and has already ingested the EAD finding aid
	(to get its ARK number assigned).  Note that the format of the
	institution's ARK number is different from the format of the
	EAD's ARK number.  Only the rightmost component of the latter is
	specified.

	Commit this file to CVS (CDL CVS repository) once it has been updated.

(2)	Step overview:  put the new contentdm export file in the file
	system.
	-----
	Receive the contentdm export file from the data analyst.  It's
	OK if there are objects associated with more than one EAD finding aid
	in one contentdm export file.  (Which EAD an object is associated
	with, is determined by the text content of its "<isPartOf>"
	element, and that need not be the same for all objects in one
	file.)

	Put the file in directory
	"voro.cdlib.org:/apps/dsc/data/oac-lsta/non-lhdrp/contentdm".

	Add and commit this file to CVS (Voro data CVS repository).

(3)     Step overview:  get enough new ARK numbers for the new contentdm
	objects, and add them into the infrastructure.
	-----
	Determine the count of new METS objects that will be created.
	One way to do that is to count the number of "<record>" elements
	in the contentdm file.  For example:

	% cd /apps/dsc/data/oac-lsta/non-lhdrp/contentdm
	% grep '<record>' ccber.xml | wc -l
	     360

	Get that many new ARK numbers, which will be assigned to the
	METS objects that will be created below.  Add the new ARK
	numbers to the "LHDRP Association" database.  If the new
	ARK numbers are in file "/abc/def/ghi", then the command to
	add them to the database is:

	% /apps/dsc/branches/production/voro/contentDM/code/LHDRPassoc.run.bash unassigned \
	? `/bin/cat /abc/def/ghi'

	Once this step is done, it should not need to be re-done, unless
	we receive an updated contentdm export file, and it contains more
	objects than the original did.  In that case, it will be necessary
	to add a number of new ARK numbers equal to the count of additional
	objects in the file.

(4)	Step overview:  verify that the "institutions.xml" file, updated
	in step (1) above contains everything necessary to process thiss
	contentdm export file.
	-----
	The data analyst says that it's possible for some objects in a
	contentdm export file to be associated with one EAD, and other
	objects to be associated with another EAD, and still other
	objects to be associated with no EAD.  If an object is associated
	with an EAD there will be a string of the form "ark:/13030/NAME"
	in the object's "<isPartOf>" element.  The value of "NAME" is
	what is used to look up the information about the institution
	that gave us the object, and about the EAD it is from.  If an
	object is associated with no EAD, there will be no "<isPartOf>"
	element.  In that case, "+default" will be used as the value of
	"NAME" when it comes to getting the information about the object's
	institution.

	Therefore, make sure that there is one "<institution>" element
	with attribute 'eadark="NAME"' in file
	"/apps/dsc/data/oac-lsta/non-lhdrp/7train/institutions.xml" for each
	finding aid mentioned in the contentdm export file, plus one
	""<institution>" element with attribute 'eadark=+default" if
	there are any objbects in the contentdm file that have no
	finding aid.

(5)	Step overview:  do a little sanity checking on the contentdm
	export file, mostly having to do with the "<identifier>" and
	"<isPartOf>" elements, and generate an XML file that can be
	run through the non-LHDRP version of 7train.
	-----
	We need to have a globally unique "<identifier>" for each contentdm
	object, that is, an "<identifier>" that will never be the same as
	any other, past, present, or future.  To that end, we require that
	the "<identifer>" values in the file be unique within the file.
	Our preprocessing step will prefix a value to the "<identifier>"
	value, such that the prefix will be unique among all contentdm
	files that we ever process.  The scheme we have settled on for
	selecting that "unique-ifying" string is to use the organization's
	MARC code, and the rightmost part of the EAD's ARK number (though
	this is not cast in stone, and a departure from this scheme won't
	hurt anything, as long as the "globally unique" aspect of the
	resulting identifier [the per-file prefix concatenated with the
	"<identifier>"s in the file] is retained).  The data analyst
	will supply this information in step (1) above.  For example,
	we have used "cstoc_kt0w1031nc_", "clo_kt638nc9ww_", and
	"ccber_kt1s20304s_".

	Then run commands:

	% cd /apps/dsc/data/oac-lsta/non-lhdrp/contentdm
	% /apps/dsc/branches/production/voro/contentDM/non-lhdrp/bin/preprocess.pl INPUTCDM OUTPUTCDM UNIQUESTRING

	If there are errors reported, pass them to the data analyst, and
	wait until a new contentdm export file is generated, then repeat
	step (2) [though the "cvs add" is not necessary; only the "cvs commit"],
	and this step.

	For example:

	% cd /apps/dsc/data/oac-lsta/non-lhdrp/contentdm
	% ../bin/preprocess.pl ccber.xml preprocessed_ccber.xml \
	? ccber_kt1s20304s_

(6)	Step overview:  create METS files.
	-----
	Because all METS files for non-LHDRP contentdm files go in the same
	directory, and because, right now, we only want to process the
	METS files that we'll be generating in this step, create a temporary
	directory in which to write the METS files for this contentdm file.
	Run 7train on the preprocessed contentdm file from step (5), and
	have it write its output in the temporary directory.

	% cd /apps/dsc/data/oac-lsta/non-lhdrp/contentdm
	% mkdir ../TEMPORARYMETS
	% ../bin/run_7train.pl OUTPUTCDM "" "" "" ../TEMPORARYMETS

	Put the newly generated METS in their final resting place, while
	still retaining them in the temporary directory.

	% cd ../TEMPORARYMETS
	% cp *.xml ../mets

	For example,

	% cd /apps/dsc/data/oac-lsta/non-lhdrp/contentdm
	% mkdir ../mets.ccber
	% ../bin/run_7train.pl preprocessed_ccber.xml "" "" "" ../mets.ccber
	% cd ../mets.ccber
	% cp *.xml ../mets

(7)	Step overview:  ingest the METS XML files into production.
	-----
	Run "getMETS.pl" on the new METS XML files.  The METS files are
	already accessible from the web, because of this symbolic link:
	lrwxrwxrwx   1 voro     voro          34 May 19 19:32 /apps/dsc/branches/production/voro/htdocs/workspace/lsta.but.non.lhdrp.mets -> /apps/dsc/data/oac-lsta/non-lhdrp/mets
	Use the list of METS files in the temporary directory to generate
	the "getMETS.pl" commands to run.

	% cd /apps/dsc/data/oac-lsta/TEMPORARYMETS
	% foreach i (`/bin/ls`)
	foreach? echo ---------- $i -----------
	foreach? /apps/dsc/branches/production/voro/batch-bin/getMETS.pl http://voro.cdlib.org:8081/workspace/lsta.but.non.lhdrp.mets/$i
	foreach? end

	For example:

	% cd /apps/dsc/data/oac-lsta/non-lhdrp/mets.ccber
	% foreach i (`/bin/ls`)
	foreach? echo ---------- $i -----------
	foreach? /apps/dsc/branches/production/voro/batch-bin/getMETS.pl http://voro.cdlib.org:8081/workspace/lsta.but.non.lhdrp.mets/$i
	foreach? end

(8)	Step overview:  add the new METS files to CVS.
	-----
	Again using the temporary directory to generate the list of METS
	files to process, run the "cvs add" and "cvs commit" commands
	to put the new METS files into CVS (Voro data CVS repository).

	% cd /apps/dsc/data/oac-lsta/non-lhdrp/mets
	% foreach i (`/bin/ls ../TEMPORARYMETS`)
	foreach? cvs add $i
	foreach? cvs commit -m "Initial file." $i
	foreach? end

	For example:

	% cd /apps/dsc/data/oac-lsta/non-lhdrp/mets
	% foreach i (`/bin/ls ../mets.ccber`)
	foreach? cvs add $i
	foreach? cvs commit -m "Initial file." $i
	foreach? end

(9)	Step overview:  delete the temporary METS directory.
	-----
	Execute:

	% /bin/rm -rf /apps/dsc/data/oac-lsta/non-lhdrp/TEMPORARYMETS

	For example:

	% /bin/rm -rf /apps/dsc/data/oac-lsta/non-lhdrp/mets.ccber
