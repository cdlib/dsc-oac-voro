#! /usr/bin/env perl

# ------------------------------------
#
# Project:	LSTA LHDRP
#
# Name:		check_cdm.pl
#
# Function:	Do some sanity checks on the contentdm XML files.
#
# Command line parameters:
#
#		1 - required - the contentdm XML file to check.
#
#		2 - required - the contributor's local id prefix.
#
#		3 - optional - a file containing the list of image files
#			we have received.  This is the output of a
#			"find . -type f -print" command in the directory
#			where the files have been placed.
#
#		4 - optional - a file into which we'll write, by append,
#			the list of files we have successfully matched.
#			But it doesn't make sense for this to be present,
#			if the list of image files (param 3) has not been
#			specified.
#
#		5 - optional - the location of the "institutions.xml"
#			file so that we can check if this institution is
#			present there.  if this parameter is omitted, or
#			is present but is of length zero, use
#			"../institutions.xml" relative to the location of
#			this script.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2008/8/5 - MAR - Initial writing
#		2008/8/7 - MAR - Add an output file into which we'll write (by
#			append) the list of files we have successfully matched.
#		2008/8/8 - MAR - Add a check for the presence of the
#			institution in "institutions.xml".
#		2008/8/8 - MAR - 7train constructs not just a TIFF URL, but
#			also a JPEG URL.  Add some checks regarding the
#			directory structure of the list of images, so that
#			we know we have a JPEG if we have a TIFF.
#		2008/8/11 - MAR - The key for looking up in "institutions.xml"
#			is changing from the "marccode" attribute to the
#			"eadark" attribute.  We get the value of "eadark"
#			out of "/metadata/record/isPartOf[1]".  Add a check
#			that it's present, and that it has an entry in
#			"institutions.xml".
#		2008/8/18 - MAR - We want to require the master image file
#			to be ".tif".
#		2009/8/11 - MAR - Cosmetic.  Change lower case "o" to upper
#			case "O" in an error message.
#		2009/8/13 - MAR - Add check that an "<identifier>" is unique
#			within a file.
#
# ------------------------------------

use strict;
use warnings;

# Pull in code we'll need.
use XML::LibXML;

# Declare our variables.
use vars qw(
	$all_without_dot
	$c
	$contentdm
	$contrib_local_id_prefix
	$corresponding_jpeg
	%file_identifiers
	$file_name
	$i
	$image_extension
	$image_list
	%images
	$input_xml
	$institution_document
	$institutions_xml
	$line_no
	$match_list
	$nearby
	$parser
	$pos
	@records
	$type_subdir
	);

# Declare subroutines we'll define later.
sub check_identifier;
sub check_is_part_of;
sub check_files;
sub check_file_existence;

# Get the command name for the error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "./";
undef $pos;

# Examine the command line parameters.
if ((scalar(@ARGV) < 1) || (length($ARGV[0]) == 0)) {
	die "$c:  the input contentdm XML file was not specified, stopped";
	}
$input_xml = $ARGV[0];

if ((scalar(@ARGV) < 2) || (length($ARGV[1]) == 0)) {
	die "$c:  the contributor's local id prefix was not specified, stopped";
	}
$contrib_local_id_prefix = $ARGV[1];

if ((scalar(@ARGV) < 3) || (length($ARGV[2]) == 0)) {
	undef $image_list;
	print STDERR "$c:  skipping the check for the presence of necessary ",
		"files\n";
	}
else {
	$image_list = $ARGV[2];
	}

if ((scalar(@ARGV) < 4) || (length($ARGV[3]) == 0)) {
	undef $match_list;
	}
else {
	if (! defined($image_list)) {
		print STDERR "$c:  the list of files was not specified, so ",
			"it makes no sense to specify an output file into ",
			"which to write the matches - ignoring command line ",
			"parameter 4 (\"$ARGV[3]\")\n";
		undef $match_list;
		}
	else {
		$match_list = $ARGV[3];
		}
	}

$institutions_xml = $nearby . "../institutions.xml";
if ((scalar(@ARGV) >= 5) && (length($ARGV[4]) != 0)) {
	$institutions_xml = $ARGV[4];
	}

if (scalar(@ARGV) > 5) {
	print STDERR "$c:  this command uses only the first 5 command ",
		"line parameters - the rest have been ignored\n";
	}

# If the user gave us a file name for the list of images, load it into a
# hash, so we can refer to it later.
if (defined($image_list)) {
	open(IMAGELST, "<", $image_list) ||
		die "$c:  unable to open \"$image_list\" for input, $!, ",
			"stopped";
	$line_no = 0;
	%images = ( );
	while(<IMAGELST>) {
		chomp;
		$line_no++;

		# Validate format of the line.
		unless (m|^\./([A-Za-z]+/(gif\|jpeg\|jpeg_l\|tiff)/(\S+\.([A-Za-z]+)))$|) {
			print STDERR "$c:  A the format of line $line_no in ",
				"\"$image_list\" is invalid - ignoring it\n";
			next;
			}
		$all_without_dot = $1;
		$type_subdir = $2;
		$file_name = $3;
		$image_extension = $4;

		# We don't care about the "checksum.fil" files, so ignore them.
		next if ($file_name eq "checksum.fil");

		# For a given subdirectory type, check that the image
		# extension is appropriate.
		if ($type_subdir eq "gif") {
			unless (lc($image_extension) eq "gif") {
				print STDERR "$c:  NOTE:  ",
					"\"$image_extension\" file is in the ",
					"\"$type_subdir\" subdirectory\n";
				}
			}
		elsif ($type_subdir eq "tiff") {
			unless (lc($image_extension) eq "tif") {
				print STDERR "$c:  NOTE:  ",
					"\"$image_extension\" file is in the ",
					"\"$type_subdir\" subdirectory\n";
				}
			}
		# The rest should be "jpeg" or "jpeg_l".
		else {
			unless (lc($image_extension) eq "jpg") {
				print STDERR "$c:  NOTE:  ",
					"\"$image_extension\" file is in the ",
					"\"$type_subdir\" subdirectory\n";
				}
			}

		# The case of the file name is probably going to matter, but we
		# need a way to check for a file without involving case.  To do
		# that, use the lower case version of the file name as the hash
		# key, and then have the hash value be an array of all the
		# permutations of case, for which we actually have a file.
		if (exists($images{lc($all_without_dot)})) {
			push @{$images{lc($all_without_dot)}}, $all_without_dot;
			}
		else {
			$images{lc($all_without_dot)} = [ $all_without_dot ];
			}
		}
	close(IMAGELST);

	# When we have a TIFF, make sure the corresponding JPEG is present.
	foreach $all_without_dot (sort keys %images) {
		# Break it up into its components.
		next unless ($all_without_dot =~
			/^([A-Za-z]+)\/tiff\/(\S+)\.tif$/);

		# Build corresponding JPEG file name.
		$corresponding_jpeg = "$1/jpeg/$2.jpg";

		# Make sure that it's there.
		unless (exists($images{$corresponding_jpeg})) {
			print STDERR "$c:  [WARNING] JPEG ",
				"\"$corresponding_jpeg\", that corresponds ",
				"to TIFF \"$all_without_dot\", is not present ",
				"in the image list \"$image_list\"\n";
			}
		}

	undef $line_no;
	undef $all_without_dot;
	undef $type_subdir;
	undef $file_name;
	undef $image_extension;
	}

# Create a parser we can use.
$parser = XML::LibXML->new( );

# Make sure that the "institutions.xml" file exists.
unless (-e $institutions_xml) {
	die "$c:  institutions XML file \"$input_xml\" does not exist, stopped";
	}
unless (-f _) {
	die "$c:  institutions XML file \"$input_xml\" is not a file, stopped";
	}

# Parse it.
eval {
	$institution_document = $parser->parse_file($institutions_xml);
	};
if (length($@) != 0) {
	die "$c:  parse of XML file \"$institutions_xml\" failed, $@, stopped";
	}

# Make sure the input file exists.  (We can give better diagnostics than
# LibXML can.)
unless (-e $input_xml) {
	die "$c:  contentdm XML file \"$input_xml\" does not exist, stopped";
	}
unless (-f _) {
	die "$c:  contentdm XML file \"$input_xml\" is not a file, stopped";
	}

# Parse the input XML file.
eval {
	$contentdm = $parser->parse_file($input_xml);
	};
if (length($@) != 0) {
	die "$c:  parse of XML file \"$input_xml\" failed, $@, stopped";
	}

# Find all the "/metadata/record" elements in the XML.
@records = $contentdm->findnodes("/metadata/record");

# If there aren't any, there's a problem.
unless (scalar(@records) > 0) {
	die "$c:  found no \"/metadata/record\" elements in ",
		"\"$input_xml\", stopped";
	}

# If we have been given one, open the match list file.
if (defined($match_list)) {
	open(MATCHLST, ">>", $match_list) ||
		die "$c:  unable to open \"$match_list\" for output, $!, ",
			"stopped";
	}

# Check each of the "<record>" elements in the "<metadata>" element.
%file_identifiers = ( );
for ($i = 0; $i < scalar(@records); $i++) {
	check_identifier($i);
	check_is_part_of($i);
	check_files($i);
	}

# Close the match list.
if (defined($match_list)) {
	close(MATCHLST);
	}

# -----
# Subroutine to check the local identifier
sub check_identifier {
	my $i = $_[0];		# Index into @records array.

	my $local_id;
	my @nodes;

	# Find the first "identifier".  Verify the format of the text in
	# that element, and verify that its prefix is what we expect it to be.
	@nodes = $records[$i]->findnodes("./identifier");
	if (scalar(@nodes) == 0) {
		print STDERR "$c:  there are no \"identifier\" elements in ",
			"\"/metadata/record[", ($i + 1), "]\" in ",
			"\"$input_xml\"\n";
		return;
		}

	# We have at least one, and we're only going to look at the first.
	$local_id = $nodes[0]->textContent( );

	# Validate the format of the identifier.
	unless ($local_id =~ /^([a-z]+)_(\d+|[a-z]+\d+_\d+)$/i) {
		print STDERR "$c:  B the format of the local id of ",
			"\"/metadata/record\" number ", ($i + 1),
			" (\"$local_id\") is invalid\n";
		return;
		}

	# Check that it's prefix is what we expect.
	if (lc($1) ne lc($contrib_local_id_prefix)) {
		print STDERR "$c:  the local id of \"/metadata/record[",
			($i + 1), "]\" (\"$local_id\") does not ",
			"have the expected prefix of ",
			"\"$contrib_local_id_prefix\"\n";
		return;
		}

	# Make sure it is unique in this file.
	if (exists($file_identifiers{$local_id})) {
		print STDERR "$c:  the local id of \"/metadata/record[",
			($i + 1), "]\" (\"$local_id\") is a duplicate of ",
			"one that occurs earlier in the file\n";
		return;
		}

	$file_identifiers{$local_id} = 1;

	# It passed all the local identifier tests.
	return;
	}

# -----
# Subroutine to check the EAD ARK number.
sub check_is_part_of {
	my $i = $_[0];		# Index into @records array.

	my @is_part_of;
	my $ead_url;
	my $ead_ark;
	my @insts;
	my $inst_marccode;

	# Find the first "isPartOf" element.
	@is_part_of = $records[$i]->findnodes("./isPartOf[1]");

	# Since we've asked only for the first, we should never get more
	# than one.
	if (scalar(@is_part_of) == 0) {
		print STDERR "$c:  there are no \"isPartOf\" elements in ",
			"\"/metadata/record[", ($i + 1), "]\" in ",
			"\"$input_xml\"\n";
		return;
		}

	# Get the text content of the first "<isPartOf>".
	$ead_url = $is_part_of[0]->textContent( );

	# Get rid of any leading or trailing white space.
	$ead_url =~ s/^\s+//;
	$ead_url =~ s/\s+$//;

	# Verify the format of the URL.
	unless ($ead_url =~ m|^http://.*/ark:/13030/([a-z0-9]+)/*$|)
		{
		print STDERR "$c:  C the format of \"/metadata/record[",
			($i + 1), "]/isPartOf[1]\" (\"$ead_url\") in ",
			"\"$input_xml\" is invalid\n";
		return;
		}
	$ead_ark = $1;

	# Look the EAD ARK number up in "institutions.xml".
	@insts = $institution_document->findnodes(
		"/institutions/institution[\@eadark='$ead_ark']");

	# There should be exactly one.
	if (scalar(@insts) == 0) {
		print STDERR "$c:  unable to determine the institution for ",
			"\"/metadata/record[", ($i + 1), "]\" in ",
			"\"$input_xml\", its first \"<isPartOf>\" contains ",
			"\"$ead_url\", but there is no institution in ",
			"\"$institutions_xml\" with an \"eadark\" attribute ",
			"of \"$ead_ark\"\n";
		return;
		}
	if (scalar(@insts) > 1) {
		print STDERR "$c:  for \"/metadata/record[", ($i + 1), "]\" ",
			"in \"$input_xml\", its first \"<isPartOf>\" contains ",
			"\"$ead_url\", and there is more than one institution ",
			" in \"$institutions_xml\" with an \"eadark\" ",
			"attribute of \"$ead_ark\"\n";
		return;
		}

	# Check that the "marccode" attribute of this institution is correct.
	$inst_marccode = $insts[0]->getAttribute("marccode");
	unless (defined($inst_marccode)) {
		print STDERR "$c:  for \"/metadata/record[", ($i + 1), "]\" ",
			"in \"$input_xml\", its first \"<isPartOf>\" contains ",
			"\"$ead_url\", and the entry in \"$institutions_xml\" ",
			"with an \"eadark\" attribute of \"$ead_ark\", has ",
			"no \"marccode\" attribute\n";
		return;
		}
	unless ($inst_marccode eq $contrib_local_id_prefix) {
		print STDERR "$c:  for \"/metadata/record[", ($i + 1), "]\" ",
			"in \"$input_xml\", its first \"<isPartOf>\" contains ",
			"\"$ead_url\", and the entry in \"$institutions_xml\" ",
			"with an \"eadark\" attribute of \"$ead_ark\", has ",
			"\"marccode\" \"$inst_marccode\", not ",
			"\"$contrib_local_id_prefix\" as expected\n";
		return;
		}
	}

# -----
# Subroutine to check that the necessary files exist, and possibly, that
# the necessary URLs retrieve something.
sub check_files {
	my $i = $_[0];		# Index into @records array.

	my @nodes;
	my @struct_kids;
	my $is_simple;
	my $j;
	my $k;
	my $image_file;
	my $file_message;
	my $page_count;
	my $node_count;
	my $first_node;
	my @pagefiles;
	my @pagefilelocations;
	my $in_node;

	# Check to see whether this is a simple object or a compound object.
	# That is based on the contents of the "<structure>" element.  Whether
	# it's simple or compound tells us where to look for the image file's
	# name, and URLs.
	@nodes = $records[$i]->findnodes("./structure");
	if (scalar(@nodes) == 0) {
		print STDERR "$c:  found no \"structure\" element in ",
			"\"/metadata/record[", ($i + 1), "]\" in ",
			"\"$input_xml\"\n";
		return;
		}

	# If we found more than one, complain, but keep going.
	if (scalar(@nodes) > 1) {
		print STDERR "$c:  found ", scalar(@nodes), " \"structure\" ",
			"elements in \"/metadata/record[", ($i + 1), "]\" in ",
			"\"$input_xml\" - examining only the first one\n";
		}

	# See what's in the "<stucture>" element.  If nothing, then I don't
	# know whether this is a simple or compound object, so I don't know
	# what to check.
	@struct_kids = $nodes[0]->childNodes( );
	if (scalar(@struct_kids) == 0) {
		print STDERR "$c:  the \"structure\" element in ",
			"\"/metadata/record[", ($i + 1), "]\" in ",
			"\"$input_xml\" is empty\n";
		return;
		}

	# See if all children of the "<structure>" are text nodes.  If so,
	# then this is a simple object.
	$is_simple = 1;
	for ($j = 0; $j < scalar(@struct_kids); $j++) {
		if ($struct_kids[$j]->nodeType( ) != XML_TEXT_NODE) {
			$is_simple = 0;
			last;
			}
		}

	if ($is_simple) {
		# It's a simple object.  Look in "<fullResolution>" for the
		# image file.
		@nodes = $records[$i]->findnodes("./fullResolution");
		if (scalar(@nodes) == 0) {
			print STDERR "$c:  \"/metadata/record[", ($i + 1),
				"]\" in \"$input_xml\" was determined ",
				"to be a simple object, but there was no ",
				"\"fullResolution\" element in it\n";
			return;
			}
		if (scalar(@nodes) > 1) {
			print STDERR "$c:  \"/metadata/record[", ($i + 1),
				"]\" in \"$input_xml\" was determined ",
				"to be a simple object, and there were ",
				scalar(@nodes), " \"fullResolution\" elements ",
				"in it - examining only the first\n";
			}

		# Pull out its text content.
		$image_file = $nodes[0]->textContent( );

		# Make sure that it's not of length zero.
		if (length($image_file) == 0) {
			print STDERR "$c:  \"/metadata/record[", ($i + 1),
				"]\" in \"$input_xml\" was determined ",
				"to be a simple object, and its ",
				"\"fullResolution\" element contains nothing\n";
			return;
			}

		# We want it to be a ".tif" file.
		unless ($image_file =~ /\.tif$/i) {
			print STDERR "$c:  \"/metadata/record[", ($i + 1),
				"]\" in \"$input_xml\" was determined ",
				"to be a simple object, and its ",
				"\"fullResolution\" element (\"$image_file\") ",
				"is not a \".tif\" file\n";
			}

		# Check if that file exists.
		$file_message = check_file_existence($image_file);
		if (defined($file_message)) {
			print STDERR "$c:  \"/metadata/record[", ($i + 1),
				"]\" in \"$input_xml\" was determined ",
				"to be a simple object, and its ",
				"\"fullResolution\" element (\"$image_file\") ",
				"$file_message\n";
			}
		}
	else {
		# It's a compound object.  Look here for the image file.

		# If it's a postcard or document compound object, then
		# there will be a series of "<page>" elements in
		# "<structure>".  If it is a monograph compound object,
		# then there is a series of "<page>" elements in the
		# ([hopefully] single) "<node>" element in "<structure>".
		# (I don't know if it's possible for there to be more than
		# one "<node>".  If there is, this code will need to be
		# expanded.)
		$page_count = 0;
		$node_count = 0;
		undef $first_node;
		for ($j = 0; $j < scalar(@struct_kids); $j++) {
			next unless ($struct_kids[$j]->nodeType( ) ==
				XML_ELEMENT_NODE);
			if ($struct_kids[$j]->nodeName( ) eq "page") {
				$page_count++;
				}
			elsif ($struct_kids[$j]->nodeName( ) eq "node") {
				$node_count++;
				unless (defined($first_node)) {
					$first_node = $struct_kids[$j];
					}
				}
			}
		if (($node_count != 0) && ($page_count != 0)) {
			print STDERR "$c:  \"/metadata/record[", ($i + 1),
				"]\" in \"$input_xml\" was determined ",
				"to be a compound object, but both ",
				"\"/metadata/record[", ($i + 1),
				"]/structure[1]/page\" and ",
				"\"/metadata/record[", ($i + 1),
				"]/structure[1]/node\" are present\n";
			return;
			}
		if (($node_count == 0) && ($page_count == 0)) {
			print STDERR "$c:  \"/metadata/record[", ($i + 1),
				"]\" in \"$input_xml\" was determined ",
				"to be a compound object, but neither ",
				"\"/metadata/record[", ($i + 1),
				"]/structure[1]/page\" nor ",
				"\"/metadata/record[", ($i + 1),
				"]/structure[1]/node\" are present\n";
			return;
			}

		# We know now that it contains only one or the other.

		# If it contains only "<node>", then get set to process inside
		# the "<node>".  (And warn that we're only looking at the first
		# one if there are more than that.)
		if ($node_count != 0) {
			if ($node_count > 1) {
				print STDERR "$c:  \"/metadata/record[",
					($i + 1), "]\" in \"$input_xml\" was ",
					"determined to be a compound object, ",
					"and \"/metadata/record[", ($i + 1),
					"]/structure[1]\" contains ",
					"$node_count \"node\" elements - ",
					"examining only the first one\n";
				}

			# Switch to looking at the "<node>" kids instead of
			# the "<structure>" kids, since the processing will
			# be the same.
			@struct_kids = $first_node->childNodes( );

			# Make sure that there are some "<page>" kids.  (If
			# we don't go through this code, i.e., if $node_count
			# is zero, then we know that $page_count is not zero.)
			$page_count = 0;
			for ($j = 0; $j < scalar(@struct_kids); $j++) {
				if ($struct_kids[$j]->nodeType( ) ==
					XML_ELEMENT_NODE) {
					if ($struct_kids[$j]->nodeName( ) eq
						"page") {
						$page_count++;
						}
					}
				}
			if ($page_count == 0) {
				print STDERR "$c:  \"/metadata/record[",
					($i + 1), "]\" in \"$input_xml\" was ",
					"determined to be a monograph ",
					"compound object, but ",
					"\"/metadata/record[", ($i + 1),
					"]/structure[1]/node[1]\" contains no ",
					"\"page\" elements\n";
				return;
				}

			# For the remaining messages, indicate that we are
			# inside "node[1]".
			$in_node = "/node[1]";
			}
		else {
			# For the remaining messages, indicate that we are
			# not inside anything.
			$in_node = "";
			}

		# At this point, we know that the count of "<page>" child
		# elements represented in @struct_kids is not zero.

		# For each "<page>" element, look for the
		# pagefile/pagefiletype==master, and get the sibling
		# pagefile/pagefilelocation.
		for ($j = 0, $k = 0; $j < scalar(@struct_kids); $j++) {
			next unless ($struct_kids[$j]->nodeType( ) ==
				XML_ELEMENT_NODE);
			next unless ($struct_kids[$j]->nodeName( ) eq "page");
			# (Maintain the "<page>" element number for error
			# messages.)
			$k++;

			# Find all the "<pagefile>" children of "<structure>"
			# or "<node>", that have a "<pagefiletype>" that
			# contains the string "master".
			@pagefiles = $struct_kids[$j]->findnodes(
				"./pagefile[pagefiletype='master']");

			# If that is zero, complain.
			if (scalar(@pagefiles) == 0) {
				print STDERR "$c:  \"/metadata/record[",
					($i + 1), "]\" in \"$input_xml\" was ",	
					"determined to be a compound object, ",
					"but no \"/metadata/record[", ($i + 1),
					"]/structure[1]$in_node/page[$k]/",
					"pagefile[pagefiletype='master']\" ",
					"element was found\n";
				next;
				}

			# If there is more than one, complain, and look at
			# only the first.
			if (scalar(@pagefiles) > 1) {
				print STDERR "$c:  \"/metadata/record[",
					($i + 1), "]\" in \"$input_xml\", was ",
					"determined to be a compound object, ",
					"and ", scalar(@pagefiles),
					" \"/metadata/record[", ($i + 1),
					"]/structure[1]$in_node/page[$k]/",
					"pagefile[pagefiletype='master']\" ",
					"elements were found - examining only ",
					"the first\n";
				}

			# Get the "pagefilelocation" children of the selected
			# "pagefile".
			@pagefilelocations = $pagefiles[0]->findnodes(
				"./pagefilelocation");
			if (scalar(@pagefilelocations) == 0) {
				print STDERR "$c:  \"/metadata/record[",
					($i + 1), "]\" in \"$input_xml\" was ",
					"determined to be a compound object, ",
					"but no \"/metadata/record[", ($i + 1),
					"]/structure[1]$in_node/page[$k]/",
					"pagefile[pagefiletype='master'][1]/",
					"pagefilelocation\" element was ",
					"found\n";
				next;
				}
			if (scalar(@pagefilelocations) > 1) {
				print STDERR "$c:  \"/metadata/record[",
					($i + 1), "]\" in \"$input_xml\" was ",
					"determined to be a compound object, ",
					"and ", scalar(@pagefilelocations),
					" \"/metadata/record[", ($i + 1),
					"]/structure[1]$in_node/page[$k]/",
					"pagefile[pagefiletype='master'][1]/",
					"pagefilelocation\" elements were ",
					"found - examining only the first ",
					"one\n";
				}

			$image_file = $pagefilelocations[0]->textContent( );

			# Make sure that it's not of length zero.
			if (length($image_file) == 0) {
				print STDERR "$c:  \"/metadata/record[",
					($i + 1), "]\" in \"$input_xml\" was ",
					"determined to be a compound object, ",
					"but its \"/metadata/record[", ($i + 1),
					"]/structure[1]$in_node/page[$k]/",
					"pagefile[pagefiletype='master'][1]/",
					"pagefilelocation[1]\" element ",
					"contains nothing\n";
				next;
				}

			# We want it to be a ".tif" file.
			unless ($image_file =~ /\.tif$/i) {
				print STDERR "$c:  \"/metadata/record[",
					($i + 1), "]\" in \"$input_xml\" was ",
					"determined to be a compound object, ",
					"and its \"/metadata/record[", ($i + 1),
					"]/structure[1]$in_node/page[$k]/",
					"pagefile[pagefiletype='master'][1]/",
					"pagefilelocation[1]\" element ",
					"(\"$image_file\") s not a \".tif\" ",
					"file\n";
				}



			# Check if that file exists.
			$file_message = check_file_existence($image_file);
			if (defined($file_message)) {
				print STDERR "$c:  \"/metadata/record[",
					($i + 1), "]\" in \"$input_xml\" was ",
					"determined to be a compound object, ",
					"and its \"/metadata/record[", ($i + 1),
					"]/structure[1]$in_node/page[$k]/",
					"pagefile[pagefiletype='master'][1]/",
					"pagefilelocation[1]\" element ",
					"(\"$image_file\") $file_message\n";
				}
			}
		}
	}

# -----
# Subroutine to check whether an image file exists.
sub check_file_existence {
	my $image_file = $_[0];

	my $file_to_check;
	my $file_extension;
	my $constructed_file_name;
	my @filename_list;
	my $i;

	# The format of an image file name in the XML is odd.  It appears
	# that there can be a directory name, followed by a backslash,
	# followed by an actual file name.  The directory name doesn't
	# appear to relate to anything.  If it's present, ignore it.
	if ($image_file =~ /[\\\/]([^\\]+)$/) {
		$file_to_check = $1;
		}
	else {
		$file_to_check = $image_file;
		}

	# It appears that the name of the file can be upper case in the XML
	# when the actual file name is lower case.  Change all the XML
	# file names to lower case.
	$file_to_check = lc($file_to_check);

	# Construct the path to the file we should have.  Leftmost is the
	# local id prefix.  In the middle is the file type of which there
	# are 4:  "gif", "jpeg", "jpeg_l", and "tiff".  Rightmost is the file
	# name we just extracted.

	# Get the file name extension.
	unless ($file_to_check =~ /\.([^.]+)$/) {
		return ("had no filename extension");
		}
	$file_extension = $1;

	# We expect a limited set of values for the file extension.
	if (lc($file_extension) eq "gif") {
		$constructed_file_name =
			"$contrib_local_id_prefix/gif/$file_to_check";
		}
	elsif (lc($file_extension) eq "tif") {
		$constructed_file_name =
			"$contrib_local_id_prefix/tiff/$file_to_check";
		}
	elsif (lc($file_extension) eq "jpg") {
		# There can be two kinds of JPEG files:  "jpeg" and "jpeg_l".
		# If the last two characters before the ".jpg" are "_l",
		# it's a "jpeg_l".  Otherwise, it's a "jpeg".
		if ($file_to_check =~ /_l\.[^.]+$/i) {
			$constructed_file_name =
				"$contrib_local_id_prefix/jpeg_l/" .
				"$file_to_check";
			}
		else {
			$constructed_file_name =
				"$contrib_local_id_prefix/jpeg/$file_to_check";
			}
		}
	else {
		return ("had an invalid filename extension of " .
			"\"$file_extension\"");
		}

	# We have done as much checking as we can if the list of files has
	# not been specified.  If the list of files wasn't given, just
	# call it good.  (We have already warned that we're not doing that
	# check this time.)
	return (undef) unless (defined($image_list));

	# Now that we have a contstructed file name, we can check to see if
	# we have that file.  The key to the hash we built is the lower case
	# version of name of the file.  The value is an array of case-
	# sensitive file names that map to that lower-case version.

	# If the lower case version is not in the hash, we don't have the file.

	unless (exists($images{lc($constructed_file_name)})) {
		return ("refers to a file we do not have");
		}

	# Pull out the array of case-sensitive names.
	@filename_list = @{$images{lc($constructed_file_name)}};

	# If our name matches one of them, everything is fine.
	for ($i = 0; $i < scalar(@filename_list); $i++) {
		if ($constructed_file_name eq $filename_list[$i]) {
			# If so requested, write this name in our match list.
			if (defined($match_list)) {
				print MATCHLST "$constructed_file_name\n";
				}
			return(undef);
			}
		}

	# It didn't match one of them.  Return a message giving the list
	# of names it was close to.
	return ("does not exactly match a file we have, but the following " .
		"files that we do have are a close match:  " .
		join(", ", @filename_list));
	}
