#! /bin/perl

# ------------------------------------
#
# Project:	LSTA LHDRP
#
# Name:		create.imgzoom.ingest.script.pl
#
# Function:	Create a script that can be run to ingest the LHDRP "tif"
#		files into the "imgzoom" server.  Use the data in a METS
#		XML file to create the "getTIFF.pl" commands necessary.
#
# Command line parameters:
#
#		1 - required - the location of the input.  this can be either
#			a single METS XML file, or a directory.  if it is a
#			directory, then process all the METS XML files in the
#			directory.
#
#		2 - required - the output file, into which the "getTIFF.pl"
#			script is to be written.
#
#		3 - optional - a file containing the list of URLs of the
#			"tif" files.  if this is omitted (or is specified but
#			is of length zero), then the third parameter on the
#			output "getTIFF.pl" commands will be not be a URL,
#			but instead, the simple name of the "tif" file.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2008/7/14 - MAR - Initial writing
#		2009/8/6 - MAR - Change to a comment.
#
# ------------------------------------

use strict;
use warnings;

# Pull in code we'll need.
use XML::LibXML;

# Declare our variables.
use vars qw(
	$c
	@dir_contents
	$highest_exit_code
	$input_location
	$line_no
	$output_file
	$parser
	$pos
	$tiff_file_name
	%url_hash
	$url_list
	@xml_files
	);

# Declare the subroutine we'll define later.
sub process_file;

# Get the command name for the error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
#$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "./";
undef $pos;

# Examine the command line parameters.
if ((scalar(@ARGV) < 1) || (length($ARGV[0]) == 0)) {
	die "$c:  the location of the input was not specified, stopped";
	}
$input_location = $ARGV[0];

if ((scalar(@ARGV) < 2) || (length($ARGV[1]) == 0)) {
	die "$c:  the location of the output file was not specified, stopped";
	}
$output_file = $ARGV[1];

undef $url_list;
if ((scalar(@ARGV) >= 3) && (length($ARGV[2]) != 0)) {
	$url_list = $ARGV[2];
	}

if (scalar(@ARGV) > 3) {
	print STDERR "$c:  this command uses only the first three command ",
		"line parameters - the rest have been ignored\n";
	}

# Check that what we have been given is valid.
unless (-e $input_location) {
	die "$c:  the input location (\"$input_location\") does not exist, ",
		"stopped";
	}

# If we were given a URL list, load it into our hash.
if (defined($url_list)) {
	open(URLS, "<", $url_list) ||
		die "$c:  unable to open \"$url_list\" for input, $!, stopped";
	%url_hash = ( );
	$line_no = 0;
	while(<URLS>) {
		chomp;
		$line_no++;

		# Verify line format, and extract the rightmost pathname
		# component.
		unless (/^http:\/\/.+\/([^\/]+)$/) {
			print STDERR "$c:  format of line $line_no in ",
				"\$url_list\" (\"$_\") is invalid - ignoring ",
				"it\n";
			next;
			}
		$tiff_file_name = $1;

		# Convert it to lower case, for use as a key in our hash,
		# to help detect duplicates.
		$tiff_file_name = lc($tiff_file_name);

		# If we have a duplicate, mention that, and ignore it.
		if (exists($url_hash{$tiff_file_name})) {
			print STDERR "$c:  \"tiff\" file name on line ",
				"$line_no in \"$url_list\" ",
				"(\"$tiff_file_name\") is a duplicate of one ",
				"on a prior line - ignoring this one\n";
			next;
			}

		# File away the URL, using the "tiff" file name as the key.
		$url_hash{$tiff_file_name} = $_;
		}

	close(URLS);
	}

# Create the parser outside the loop.
$parser = XML::LibXML->new( );

# Open the output file.
open(OUTF, ">", $output_file) ||
	die "$c:  unable to open \"$output_file\" for output, $!, stopped";

# If the input is a file, process it.
$highest_exit_code = 0;
if (-f $input_location) {
	process_file($input_location);
	}

# Or, if it's a directory, process all the XML files in it.
elsif (-d _) {
	opendir(DIR, $input_location) ||
		die "$c:  unable to open directory \"$input_location\", $!, ",
			"stopped";
	@dir_contents = readdir(DIR);
	closedir(DIR);

	# Construct the list of XML files in the directory.
	@xml_files = ( );
	foreach (@dir_contents) {
		next unless (/\.mets\.xml$/);
		push @xml_files, "$input_location/$_";
		}
	undef @dir_contents;

	# If there are no XML files in this directory, complain.
	if (scalar(@xml_files) == 0) {
		die "$c:  there are no XML files in directory ",
			"\"$input_location\", stopped";
		}

	# Process each XML file we found.
	foreach (@xml_files) {
		process_file($_);
		}
	}

# Otherwise, complain.
else {
	die "$c:  the input location (\"$input_location\") is neither a ",
		"file nor a directory, stopped";
	}

# Close the output file.
close(OUTF);

# Exit with the highest exit code we encountered.
exit($highest_exit_code);

# -----
# Subroutine to process one file.
sub process_file {
	my $input_file = $_[0];

	my $ark_number;
	my $document;
	my $find_tiff_hrefs;
	my $i;
	my @nodes;
	my @sorted_tiff_files;
	my @tiff_files;
	my $tiff_url;
	my $output_tiff;

	# Parse the XML file.
	eval {
		$document = $parser->parse_file($input_file);
		};
	if (length($@) != 0) {
		print STDERR "$c:  attempt to parse \"$input_file\" failed, ",
			"$@ - skipping that file\n";
		$highest_exit_code = 1 if (1 > $highest_exit_code);
		return;
		}

	# Get the document's ARK number.
	$ark_number = $document->documentElement( )->getAttribute("OBJID");
	unless (defined($ark_number) && (length($ark_number) != 0)) {
		print STDERR "$c:  unable to find the \"OBJID\" attribute ",
			"of the document element in \"$input_file\" - ",
			"skipping that file\n";
		$highest_exit_code = 1 if (1 > $highest_exit_code);
		return;
		}

	# Get the links to the TIFF files.
	$find_tiff_hrefs = "/mets:mets/" .
		"mets:fileSec/" .
		"mets:fileGrp[\@USE='archive image']/" .
		"mets:file[\@MIMETYPE='image/tiff']/" .
		"mets:FLocat/" .
		"\@xlink:href";
	@nodes = $document->findnodes($find_tiff_hrefs);

	# If we found none, there's a problem.
	if (scalar(@nodes) == 0) {
		print STDERR "$c:  unable to find any TIFF \"href\"s in ",
			"\"$input_file\" (because nothing matches the XPATH ",
			"expression \"$find_tiff_hrefs\" - skipping that XML ",
			"file\n";
		$highest_exit_code = 1 if (1 > $highest_exit_code);
		return;
		}

	# Develop the list of file names.
	@tiff_files = ( );
	for ($i = 0; $i < scalar(@nodes); $i++) {
		# Fetch the attribute's value.
		$tiff_url = $nodes[$i]->getValue( );

		# Make sure it looks like a URL for a TIFF file.
		unless ($tiff_url =~ /^http:\/\/.+\/([^\/]+)$/) {
			print STDERR "$c:  the value of \"xlink:href\" ",
				"attribute number ", ($i + 1),
				" (\"$tiff_url\") that matches XPATH ",
				"expression \"$find_tiff_hrefs\" in XML file ",
				"\"$input_file\" does not appear to be a ",
				"URL for a TIFF file - skipping that XML ",
				"file\n";
			$highest_exit_code = 1 if (1 > $highest_exit_code);
			return;
			}

		# Use the lower case version of the TIFF file.
		push @tiff_files, lc($1);
		}

	# The component id that we'll use in the "getTIFF.pl" command is
	# something we manufacture.  It is essentially the ordinal number
	# of the image within the set of images for the object.  It's
	# either the order of the images as they appear in the METS file,
	# or the order of the images by sorted file name.  The two orders
	# should be the same.  We check for that sameness here.
	@sorted_tiff_files = sort(@tiff_files);

	for ($i = 0; $i < scalar(@tiff_files); $i++) {
		unless ($tiff_files[$i] eq $sorted_tiff_files[$i]) {
			print STDERR "$c:  [WARNING] the order in which the ",
				"TIFF URLs appear in \"$input_file\" is not ",
				"the same as the alphabetic order of the ",
				"names of the TIFF files - using the ",
				"appearance order\n";
			last;
			}
		}

	# Write out the "getTIFF.pl" commands.
	for ($i = 0; $i < scalar(@tiff_files); $i++) {
		# Set the name of the TIFF file to be is plain name.
		$output_tiff = $tiff_files[$i];

		# If we have actual URLs for the TIFFs, use them.
		if (defined($url_list)) {
			if (exists($url_hash{$tiff_files[$i]})) {
				$output_tiff = $url_hash{$tiff_files[$i]};
				}
			else {
				print STDERR "$c:  no URL was found for TIFF ",
					"file \"$tiff_files[$i]\" in XML file ",
					"\"$input_file\"\n";
				}
			}

		# Write out the ingest command.
		print OUTF "getTIFF.pl $ark_number z", ($i + 1), " '",
			$output_tiff, "'\n";
		}

	return;
	}
