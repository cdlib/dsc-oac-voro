#! /usr/bin/perl

# ------------------------------------
#
# Project:	OAC
#
# Name:		lis.all.href.pl
#
# Function:	Write out the URLs of all "xlink:href" attributes of
#		"mets:FLocat"s, so we can check that they refer to something.
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
	$c
	$cmd
	@cmd_out
	$contrib
	@contrib_list
	@dir_contents
	$dir_entry
	$exit_code
	@hrefs
	$input_dir
	$input_document
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

# Pull in code we'll need.
use XML::LibXML;

# Identify the contributors.
@contrib_list = ("csmat", "caarpl", "csb", "cwh");

# Create the parser outside the loop.
$parser = XML::LibXML->new( );

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
			print $_->getValue( ), "\n";
			}
		}
	}
