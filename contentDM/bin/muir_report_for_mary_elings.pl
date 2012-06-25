#! /usr/bin/perl

# ------------------------------------
#
# Project:	LSTA Muir Letters
#
# Name:		muir_report_for_mary_elings.pl
#
# Function:	For each the Muir Letters METS, list the ARK URL, the
#		title (from contentdm <title>), the date (from contentdm
#		<created>), and the local identifier (from contentdm
#		<identifier>).
#
# Command line parameters:  none
#
# Note:		Looks at all METS files in "/voro/data/oac-lsta/non-lhdrp/mets".
#
# Note:		Writes report in "muir_report.utf8" in the same directory
#		as this script.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2009/7/1 - MAR - Initial writing
#
# ------------------------------------

use strict;
use warnings;

# Pull in code we'll need
use XML::LibXML;

# Declare our variables.
use vars qw(
	$ark_number
	$c
	$date
	@dir_contents
	$dir_entry
	$document
	$identifier
	$mets_dir
	$nearby
	@nodes
	$output_file
	$parser
	$pos
	$title
	);

# Get the command name for the error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "";
$nearby = "./" if ($nearby eq "");
undef $pos;

# Identify the directory that holds the METS XML files.
$mets_dir = "/voro/data/oac-lsta/non-lhdrp/mets";

# Identify our output file.
$output_file = $nearby . "muir_report.utf8";

# Examine command line parameters.
if (scalar(@ARGV) > 0) {
	print STDERR "$c:  this script uses no command line parameters - ",
		"all have been ignored\n";
	}

# Create a parser.
$parser = XML::LibXML->new( );

# Get the list of METS files we'll process.
opendir(DIR, $mets_dir) ||
	die "$c:  unable to open directory \"$mets_dir\", $!, stopped";
@dir_contents = readdir(DIR);
closedir(DIR);
@dir_contents = sort(@dir_contents);

# Open our output file.
open(OUTF, ">:utf8", $output_file) ||
	die "$c:  unable to open \"$output_file\" for output, $!, stopped";

# Process the METS files.
foreach $dir_entry (@dir_contents) {
	# Skip "." and ".." as a matter of course.
	next if ($dir_entry eq ".");
	next if ($dir_entry eq "..");

	# If it's not a file, complain, and skip it.
	unless (-f "$mets_dir/$dir_entry") {
		print STDERR "$c:  skipping \"$mets_dir/$dir_entry\" ",
			"because it is not a file\n";
		next;
		}

	# If it's not a METS XML file, compalin, and skip it.
	unless ($dir_entry =~ /^([a-z0-9]+)\.mets\.xml$/) {
		print STDERR "$c:  skipping \"$mets_dir/$dir_entry\" ",
			"because it is not a METS XML file\n";
		next;
		}
	$ark_number = "ark:/13030/$1";

	# Parse the file.
	eval {
		$document = $parser->parse_file("$mets_dir/$dir_entry");
		};
	if (length($@) != 0) {
		die "$c:  unable to parse \"$mets_dir/$dir_entry\", $@, ",
			"stopped";
		}

	# Get the title.
	@nodes = $document->findnodes("/mets:mets/mets:dmdSec[\@ID = 'DC']" .
		"/mets:mdWrap/mets:xmlData/dc:title");
	unless (scalar(@nodes) == 1) {
		print "$c:  found ", scalar(@nodes), " titles for ",
			"$dir_entry - skipping it\n";
		next;
		}
	$title = $nodes[0]->textContent( );

	# Get the date.
	@nodes = $document->findnodes("/mets:mets/mets:dmdSec[\@ID = 'DC']" .
		"/mets:mdWrap/mets:xmlData/dc:date[1]");
	unless (scalar(@nodes) == 1) {
		print "$c:  found ", scalar(@nodes), " dates for ",
			"$dir_entry - skipping it\n";
		next;
		}
	$date = $nodes[0]->textContent( );

	# Get the identifier.
	@nodes = $document->findnodes("/mets:mets/mets:dmdSec[\@ID = 'DC']" .
		"/mets:mdWrap/mets:xmlData/dc:identifier");
	unless (scalar(@nodes) == 1) {
		print "$c:  found ", scalar(@nodes), " identifiers for ",
			"$dir_entry - skipping it\n";
		next;
		}
	$identifier = $nodes[0]->textContent( );

	# Write out the data.
	print OUTF "http://content.cdlib.org/$ark_number\n";
	print OUTF "$title\n";
	print OUTF "$date\n";
	print OUTF "$identifier\n";
	print OUTF "\n";
	}

# Close output file.
close(OUTF);
