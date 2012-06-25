#! /usr/bin/perl

# ------------------------------------
#
# Project:	OAC
#
# Name:		check.all.href.pl
#
# Function:	Look at the URLs of all the "xlink:href" attributes.  See if
#		the files exist.  URLs beginning with
#		"http://content.cdlib.org/dynaxml/data/13030" can be checked
#		on this machine. 
#
#		For URLs beginning with "http://ingest1.cdlib.org/LSTA-2ndGen/"
#		refer to the "find ... -print" output run on "ingest1".
#
# Input:	"files.on.ingest1" in the same directory as this script.
#
# Command line parameters:  none.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2007/7/24 - MAR - Initial writing
#
# ------------------------------------

use warnings;
use strict;
use vars qw(
	$an_href
	$c
	$contrib
	@contrib_list
	@dir_contents
	$dir_entry
	$exit_code
	@hrefs
	%ingest1_files
	$ingest1_name
	$input_dir
	$input_document
	$local_dir
	$mets_xml
	$nearby
	$parser
	$pos
	);

# Get command name for error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "./";
$nearby = "" if ($nearby eq "./");
undef $pos;

# Identify where we'll put the output METS XML.
$input_dir = $nearby . "fixed.mets";

# Identify the local directory to check for file presence.
$local_dir = "/texts/xtf/data/13030";

# Pull in code we'll need.
use XML::LibXML;

# Identify the contributors.
@contrib_list = ("csmat", "caarpl", "csb", "cwh");

# Create the parser outside the loop.
$parser = XML::LibXML->new( );

# Load the list of files on "ingest1";
$ingest1_name = $nearby . "files.on.ingest1";
open(ING1, "<", $ingest1_name) ||
	die "$c:  unable to open \"$ingest1_name\" for input, $!, stopped";
%ingest1_files = ( );
while(<ING1>) {
	chomp;
	$ingest1_files{$_} = 1;
	}
close(ING1);

# Process each contributor.
foreach $contrib (@contrib_list) {
	opendir(DIR, "$input_dir/$contrib") ||
		die "$c:  opendir of \"$input_dir/$contrib\" failed, $!, ",
			"stopped";
	@dir_contents = readdir(DIR);
	closedir(DIR);

	foreach $dir_entry (@dir_contents) {
		next if ($dir_entry eq ".");
		next if ($dir_entry eq "..");
		next unless ($dir_entry =~ /\.mets\.xml$/);

		# Identify the file.
		$mets_xml = "$input_dir/$contrib/$dir_entry";

		# Parse it.
		eval {
			$input_document =
				$parser->parse_file($mets_xml);
			};
		if (length($@) != 0) {
			die "$c:  attempt to parse \"$mets_xml\", ",
				"$@, stopped";
			}

		# Get all the "xlink:href" attributes in the file.
		@hrefs = $input_document->findnodes("/mets:mets/mets:fileSec" .
			"/mets:fileGrp/mets:file/mets:FLocat/\@xlink:href");

		foreach (@hrefs) {
			$an_href = $_->getValue( );

			# See which kind of URL it is.
			if ($an_href =~
				m|http://content.cdlib.org/dynaxml/data/13030/(.+)$|) {
				unless (-e "$local_dir/$1") {
					print "$c:  not on content \"$1\"\n";
					}
				}
			elsif ($an_href =~
				m|http://ingest1.cdlib.org/LSTA-2ndGen/(.+)$|) {
				unless (exists($ingest1_files{$1})) {
					print "$c:  not on ingest1 \"$1\"\n";
					}
				}
			else {
				print "$c:  URL not of either type that was ",
					"expected \"$an_href\"\n";
				}
			}
		}
	}
