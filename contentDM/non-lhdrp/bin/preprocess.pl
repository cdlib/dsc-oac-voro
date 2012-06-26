#! /usr/bin/perl

# ------------------------------------
#
# Project:	non-LHDRP contentdm processing
#
# Name:		preprocess.pl
#
# Function:	Pre-process the contentdm export file.
#
# Command line parameters:
#
#		1 - required - the location of the input contentdm file.
#
#		2 - required - the location of the output contentdm file.
#
#		3 - required - the string that is unique to the contentdm
#			export file that is being processed (so that
#			when it is concatenated with the local identifier
#			of an object, the result will be a globally unique
#			identifier for the object (and can be used to make
#			a unique association with a unique ARK number).
#
#		4 - optional - the location of the "institutions.xml"
#			file that contains information about institutions
#			and finding aids.  the default (if this parameter is
#			omitted or of length zero) is
#			"../7train/institutions.xml" relative to the location
#			of this script.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2009/5/15 - MAR - Initial writing
#		2009/8/13 - MAR - Add some checks on the "<identifier>"s:
#			they shouldn't contain white space, should probably
#			consist only of letters, numbers, and a limited set
#			of (arbitrary) punctuation characters.  Also, they
#			need to be unique within the file.
#
# ------------------------------------

use strict;
use warnings;

# Declare our variables.
use vars qw(
	$ark_name
	$c
	$contentdm_document
	%file_identifiers
	$i
	$input_contentdm
	$institutions_document
	$institutions_xml
	$is_part_of
	$j
	$local_id
	$output_contentdm
	$nearby
	@nodes
	$new_element
	$parser
	$pos
	@records
	$unique_ifier
	);

# Pull in code we'll need.
use XML::LibXML;

# Get the command name for the error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "";
$nearby = "./" if ($nearby eq "");
undef $pos;

# Examine command line parameters.
if ((scalar(@ARGV) >= 1) && (length($ARGV[0]) > 0)) {
	$input_contentdm = $ARGV[0];
	}
else {
	die "$c:  name of input contentdm file was omitted, stopped";
	}

if ((scalar(@ARGV) >= 2) && (length($ARGV[1]) > 0)) {
	$output_contentdm = $ARGV[1];
	}
else {
	die "$c:  name of output contentdm file was omitted, stopped";
	}

if ((scalar(@ARGV) >= 3) && (length($ARGV[2]) > 0)) {
	$unique_ifier = $ARGV[2];
	}
else {
	die "$c:  the unique string for this contentdm file was omitted, ",
		"stopped";
	}

if ((scalar(@ARGV) >= 4) && (length($ARGV[3]) > 0)) {
	$institutions_xml = $ARGV[3];
	}
else {
	$institutions_xml = $nearby . "../7train/institutions.xml";
	}

if (scalar(@ARGV) > 4) {
	print STDERR "$c:  this script uses only 4 command line parameters - ",
		"all beyond that have been ignored\n";
	}

# Create a parser.
$parser = XML::LibXML->new( );

# Parse the "institutions.xml" file.
eval {
	$institutions_document = $parser->parse_file($institutions_xml);
	};
if (length($@) != 0) {
	die "$c:  unable to parse \"$institutions_xml\", $@, stopped";
	}

# Parse the input file.
eval {
	$contentdm_document = $parser->parse_file($input_contentdm);
	};
if (length($@) != 0) {
	die "$c:  unable to parse \"$input_contentdm\", $@, stopped";
	}

# Get the list of "<record>" elements.
@records = $contentdm_document->findnodes("/metadata/record");

# If there were none, complain.
if (scalar(@records) == 0) {
	die "$c:  there were no <record> elements in \"$input_contentdm\", ",
		"stopped";
	}

# Process each "<record>".
%file_identifiers = ( );
for ($i = 0; $i < scalar(@records); $i++) {
	# We have seen some empty "<identifier>"s preceding the ones we
	# want.  Remove those.
	@nodes = $records[$i]->findnodes("identifier");
	if (scalar(@nodes) == 0) {
		die "$c:  there is no <identifier> within <record> number ",
			($i + 1), " in \"$input_contentdm\", stopped";
		}

	# If there is only one, check that it has some non-white-space text
	# content.
	if (scalar(@nodes) == 1) {
		$local_id = $nodes[0]->textContent( );
		if ($local_id =~ /^\s*$/) {
			die "$c:  there is nothing in the single <identifier> ",
				"within <record> number ", ($i + 1),
				" in \"$input_contentdm\", stopped";
			}
		}

	# If there is more than one, remove <identifier> elements if
	# they have nothing, or at most white space, as their text content.
	# (So that we leave things such that the first <identifier> has
	# something in it.)
	if (scalar(@nodes) > 1) {
		undef $local_id;
		for ($j = 0; $j < scalar(@nodes); $j++) {
			$local_id = $nodes[$j]->textContent( );
			if ($local_id =~ /^\s*$/) {
				$records[$i]->removeChild($nodes[$j]);
				undef $local_id;
				next;
				}
			last;
			}
		unless (defined($local_id)) {
			die "$c:  all ", scalar(@nodes), " <identifier> ",
				"elements within <record> number ", ($i + 1),
				" in \"$input_contentdm\" are devoid of text ",
				"content, stopped";
			}
		}

	# The "<identifier>" shouldn't have white space in it.
	if ($local_id =~ /\s/) {
		die "$c:  in <record> number ", ($i + 1), " in ",
			"\"$input_contentdm\", the selected <identifier> ",
			"(\"$local_id\") contains white space, stopped";
		}

	# Warn if the identifier contains other than letters, numbers, and
	# a few (arbitrary) punctuation characters.
	unless ($local_id =~ /^[-A-Za-z0-9_.=]+$/) {
		print STDERR "$c: [WARNING] in <record> number ", ($i + 1),
			" in \"$input_contentdm\", the selected <identifier> ",
			"(\"$local_id\") contains other than letters numbers, ",
			"hyphens, underscores, periods, and equal signs\n";
		}
	if (exists($file_identifiers{$local_id})) {
		die "$c:  in <record> number ", ($i + 1), " in ",
			"\"$input_contentdm\", the selected <identifier> ",
			"(\"$local_id\") duplicates one that occurs earlier ",
			"in the file, stopped";
		}
	$file_identifiers{$local_id} = 1;

	# Add an element, which 7train won't know about, so will skip, that
	# will contain the globally unique identifier for this object.
	$new_element = $contentdm_document->createElement(
		"globallyUniqueIdentifierForCDL");
	$new_element->appendChild($contentdm_document->createTextNode(
		$unique_ifier . $local_id));
	$records[$i]->appendChild($new_element);

	# See if we have an "<isPartOf>" in this object.
	@nodes = $records[$i]->findnodes("isPartOf");

	# If we don't have any, there's nothing we need to do.  If one is
	# present, though, then we had better be able to find an
	# ARK number in its text content.
	if (scalar(@nodes) > 0) {
		$is_part_of = $nodes[0]->textContent( );
		unless ($is_part_of =~ m|ark:/13030/([a-z0-9]+)|) {
			die "$c:  there is no identifiable ARK number in the ",
				"text (\"$is_part_of\") of the first ",
				"<isPartOf> of <record> number ", ($i + 1),
				" in \"$input_contentdm\", stopped";
			}
		$ark_name = $1;
		}
	else {
		$ark_name = "+default";
		}

	# Make sure that we have an institution in our "institutions.xml"
	# file with that ARK number (really just the ARK name).
	@nodes = $institutions_document->findnodes(
		"/institutions/institution[\@eadark='$ark_name']");
	if (scalar(@nodes) == 0) {
		die "$c:  there is no institution in \"$institutions_xml\" ",
			"that has eadark \"$ark_name\" which is the ead for ",
			"<record> number ", ($i + 1),
			" in \"$input_contentdm\", stopped";
		}

	# Put in another element that 7train won't know about, but will
	# help us.
	$new_element = $contentdm_document->createElement(
		"institutionFinderForCDL");
	$new_element->appendChild($contentdm_document->createTextNode(
		$ark_name));
	$records[$i]->appendChild($new_element);
	}

# Write out (possibly changed) XML.
$contentdm_document->toFile($output_contentdm);
