#! /bin/perl

# ------------------------------------
#
# Project:	LSTA LHDRP
#
# Name:		generate.DPR.lists.pl
#
# Function:	Create the lists of URLs that the DPR folks need in order
#		to ingest the LHDRP METS into DPR.
#
# Command line parameters:
#
#		1 - required - the subdirectory of the generated METS directory
#			in which this year's METS files have been placed
#
#		2 - required - the directory into which to place the output
#			files (the lists of URLs).
#
#		3 - optional - the main LHDRP METS directory.  if this
#			parameter is omitted, or is present and is of length
#			zero, use "/voro/data/oac-lsta/mets".
#
#		4 - optional - the URL used to access the main LHDRP METS
#			directory.  if this parameter is omitted, or is present
#			and is of length zero, use
#			"http://voro.cdlib.org:8081/workspace/lhdrp.mets".
#
#		5 - optional - the "institutions.xml" file.  if this parameter
#			is omitted, or is present and is of length zero, use
#			"../institutions.xml" in relation to this script.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2008/8/18 - MAR - Initial writing
#
# ------------------------------------

use strict;
use warnings;

# Pull in code we'll need.
use XML::LibXML;

# Declare our variables.
use vars qw(
	@list_eadark
	@list_index
	@list_mets
	$attr_name
	$attr_value
	@attributes
	$c
	$dir_entry
	$eadark
	%eadark_to_ead_label
	%eadark_to_inst_ark
	%eadark_to_inst_marc_code
	%eadark_to_inst_name
	%eadark_to_inst_url
	$findnodes_eadark
	$i
	$input_subdir
	$institutions_file
	$main_mets_dir
	$main_mets_url
	@mets_files
	$nearby
	@nodes
	$output_dir
	$output_file
	$output_file_number
	$parser
	$pos
	$prev_eadark
	$xml_dom
	);

# Get the command name for the error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "./";
undef $pos;

# Examine the command line parameters.
if ((scalar(@ARGV) < 1) || (length($ARGV[0]) == 0)) {
	die "$c:  the METS subdirectory was not specified, stopped";
	}
$input_subdir = $ARGV[0];

if ((scalar(@ARGV) < 2) || (length($ARGV[1]) == 0)) {
	die "$c:  the output directory was not specified, stopped";
	}
$output_dir = $ARGV[1];

if ((scalar(@ARGV) >= 3) && (length($ARGV[2]) != 0)) {
	$main_mets_dir = $ARGV[2];
	}
else {
	$main_mets_dir = "/voro/data/oac-lsta/mets";
	}

if ((scalar(@ARGV) >= 4) && (length($ARGV[3]) != 0)) {
	$main_mets_url = $ARGV[3];
	}
else {
	$main_mets_url = "http://voro.cdlib.org:8081/workspace/lhdrp.mets";
	}

if ((scalar(@ARGV) >= 5) && (length($ARGV[4]) != 0)) {
	$institutions_file = $ARGV[4];
	}
else {
	$institutions_file = $nearby . "../institutions.xml";
	}

if (scalar(@ARGV) > 5) {
	print STDERR "$c:  this command uses only the first 5 command ",
		"line parameters - the rest have been ignored\n";
	}

# Create an XML parser.
$parser = XML::LibXML->new( );

# Parse the "institutions.xml" file.
eval {
	$xml_dom = $parser->parse_file($institutions_file);
	};
if (length($@) != 0) {
	die "$c:  attempt to parse \"$institutions_file\" as XML failed, $@, ",
		"stopped";
	}

# Convert the XML data to hashes.
%eadark_to_ead_label = ( );
%eadark_to_inst_ark = ( );
%eadark_to_inst_marc_code = ( );
%eadark_to_inst_name = ( );
%eadark_to_inst_url = ( );
@nodes = $xml_dom->findnodes("/institutions/institution");
if (scalar(@nodes) == 0) {
	die "$c:  found no \"/institutions/institution\" in the XML in ",
		"\"$institutions_file\", stopped";
	}
for ($i = 0; $i < scalar(@nodes); $i++) {
	@attributes = ( );
	for $attr_name ("eadark", "eadlabel", "ark", "marccode", "name",
		"url") {
		$attr_value = $nodes[$i]->getAttribute($attr_name);
		unless (defined($attr_value) && (length($attr_value) > 0)) {
			die "$c:  the value of the \"$attr_name\" attribute ",
				"on \"/institutions/instutution[", ($i + 1),
				"]\" in \"$institutions_file\" is missing or ",
				"of length zero, stopped";
			}
		push @attributes, $attr_value;
		}

	# File the values away in their hashes.
	$eadark_to_ead_label{$attributes[0]} = $attributes[1];
	$eadark_to_inst_ark{$attributes[0]} = $attributes[2];
	$eadark_to_inst_marc_code{$attributes[0]} = $attributes[3];
	$eadark_to_inst_name{$attributes[0]} = $attributes[4];
	$eadark_to_inst_url{$attributes[0]} = $attributes[5];
	}
undef $xml_dom;
undef @nodes;

# Get the names of all the METS files.
opendir(DIR, "$main_mets_dir/$input_subdir") ||
	die "$c:  unable to open directory \"$main_mets_dir/$input_subdir\", ",
		"$!, stopped";
@mets_files = readdir(DIR);
closedir(DIR);

# Examine all the METS files.
@list_eadark = ( );
@list_mets = ( );
foreach $dir_entry (@mets_files) {
	# Ignore "." and "..".
	next if ($dir_entry eq ".");
	next if ($dir_entry eq "..");

	# Ignore an entry unless it's a METS file.
	next unless ($dir_entry =~ /\.mets\.xml$/);
	next unless (-f "$main_mets_dir/$input_subdir/$dir_entry");

	# Parse the MET XML file.
	eval {
		$xml_dom = $parser->parse_file(
			"$main_mets_dir/$input_subdir/$dir_entry");
		};
	if (length($@) != 0) {
		die "$c:  attempt to parse \"$main_mets_dir/$input_subdir/",
			"$dir_entry\" as XML failed, $@, stopped";
		}

	# Get the EAD ARK number.
	$findnodes_eadark =
		"/mets:mets/mets:dmdSec[\@ID='ead']/mets:mdRef/\@ID";
	@nodes = $xml_dom->findnodes($findnodes_eadark);
	if (scalar(@nodes) != 1) {
		die "$c:  expected 1 value for XPATH request ",
			"\"$findnodes_eadark\" in the XML in file ",
			"\"$main_mets_dir/$input_subdir/$dir_entry\", found ",
			scalar(@nodes), " values, stopped";
		}

	$eadark = $nodes[0]->getValue( );
	unless (defined($eadark) && (length($eadark) > 0)) {
		die "$c:  value for attribute found by XPATH request ",
			"\"$findnodes_eadark\" in the XML in file ",
			"\"$main_mets_dir/$input_subdir/$dir_entry\" was ",
			"missing or of length zero, stopped";
		}

	# Make sure we have info on it.
	unless (exists($eadark_to_ead_label{$eadark})) {
		die "$c:  EAD ARK number \"$eadark\" in file ",
			"\"$main_mets_dir/$input_subdir/$dir_entry\" is ",
			"not present in \"$institutions_file\", stopped";
		}

	# Everything looks good.  Save both the file name, and the
	# EAD ARK number, at the same positions in different arrays.
	push @list_eadark, $eadark;
	push @list_mets, $dir_entry;
	}
undef $parser;
undef @nodes;
undef @mets_files;
undef $dir_entry;

# Group all the METS files together by their EAD ARK number.  (Sort them
# the EAD ARK number.)
@list_index = ( );
for ($i = 0; $i < scalar(@list_eadark); $i++) {
	$list_index[$i] = $i;
	}

@list_index = sort {
	$list_eadark[$a] cmp $list_eadark[$b];
	} @list_index;

# Write out each group.
$prev_eadark = "";
$output_file = "";
$output_file_number = 0;
for ($i = 0; $i < scalar(@list_index); $i++) {
	# Pull out the EAD ARK number.
	$eadark = $list_eadark[$list_index[$i]];

	# If it is not the same as the previous one, close the old file,
	# and open the new one.
	if ($prev_eadark ne $eadark) {
		# If there was a previous one, close the old file.
		if (length($output_file) != 0) {
			close(OUTF);
			}

		# Generate the output file name.
		$output_file_number++;
		$output_file = "$output_dir/urls$output_file_number.txt";

		# Open the output file.
		open(OUTF, ">", $output_file) ||
			die "$c:  unable to open \"$output_file\" for ",
				"output, $!, stopped";

		# Write out the heading information about this EAD and
		# contributor.
		print OUTF "Institution Name = ", $eadark_to_inst_name{$eadark},
			"\n";
		print OUTF "Institution ARK = ", $eadark_to_inst_ark{$eadark},
			"\n";
		print OUTF "Institution MARC Code/voroEAD directory = ",
			$eadark_to_inst_marc_code{$eadark}, "\n";
		print OUTF "Institution URL = ", $eadark_to_inst_url{$eadark},
			"\n";
		print OUTF "Finding Aid Title = ",
			$eadark_to_ead_label{$eadark}, "\n";
		print OUTF "Finding Aid ARK = http://ark.cdlib.org/ark:/13030/",
			$eadark, "\n";
		print OUTF "\n";

		# Indicate that we have started this EAD ARK number.
		$prev_eadark = $eadark;
		}

	# Print the URL.
	print OUTF $main_mets_url, "/", $input_subdir, "/",
		$list_mets[$list_index[$i]], "\n";
	}

# Close the output file (if we ever opened one).
if (length($output_file) != 0) {
	close(OUTF);
	}
