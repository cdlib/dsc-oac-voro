#! /usr/bin/perl

# ------------------------------------
#
# Project:	LSTA Muir Letters
#
# Name:		postprocess_muir_mets.pl
#
# Function:	Change " br "s in "<transcription>" elements to "<br/>"s
#		(if that has not already been done), in the Muir Correspondence
#		METs.  Because I set things up to put all the METS files in
#		a single directory, select only the Muir Correspondence
#		METS for processing.  Write the corrected METS over the
#		input METS.
#
# Command line parameters:
#		1 - optional - the directory that contains the METS XML
#			files.  if this parameter is omitted, or is present
#			and of length zero, use "../mets" relative to the
#			location of this script.
#
# Author:	Michael A. Russell
#
# Revision History:
#		2009/8/18 - MAR - Initial writing
#
# ------------------------------------

use strict;
use warnings;

# Pull in code we'll need
use XML::LibXML;

# Declare our variables.
use vars qw(
	$assoc_data
	$c
	$changed_muir_mets_xml_files
	@children
	@dir_contents
	$dir_entry
	$document
	$has_br_child
	$input_dir
	$lhdrp_assoc_command
	$muir_identifier_prefix
	%muir_mets
	$muir_mets_xml_files
	$nearby
	$node
	@nodes
	$parser
	$pos
	$temp_file
	$text_content
	$transcription_fixed
	);

# Get the command name for the error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "";
$nearby = "./" if ($nearby eq "");
undef $pos;

# Examine command line parameters.
if ((scalar(@ARGV) >= 1) && (length($ARGV[0]) != 0)) {
	$input_dir = $ARGV[0];
	}
else {
	$input_dir = $nearby . "../mets";
	}
if (scalar(@ARGV) > 1) {
	print STDERR "$c:  this script uses only 1 command line parameter - ",
		"all beyond that have been ignored\n";
	}

# Get the ARK numbers for the Muir Correspondence METS.  We'll use this
# command to get them:
$lhdrp_assoc_command = "/voro/data/oac-lsta/admin/code/LHDRPassoc.run.csh " .
	"dump -";

# And we'll select lines from the output of that command that have this
# "<identifier>" prefix value:
$muir_identifier_prefix = "cstoc_kt0w1031nc_";

# Populate the hash that tells us which METS files are for the Muir
# Correspondence.
open(ASSOC, "-|", $lhdrp_assoc_command) ||
	die "$c:  unable to run command \"$lhdrp_assoc_command\", which ",
		"is needed to determine which METS files are for the ",
		"Muir Correspondence, $!, stopped";
%muir_mets = ( );
while(<ASSOC>) {
	chomp;
	# Skip lines that are not for non-LHDRP METS.
	next unless (/^nonLHDRP-(.+)$/);
	$assoc_data = $1;

	# Skip lines that don't have the "<identifier>" prefix of the
	# Muir Correspondence.
	next unless (length($assoc_data) > length($muir_identifier_prefix));
	next unless (substr($assoc_data, 0, length($muir_identifier_prefix)) eq
		$muir_identifier_prefix);

	# If the format of the line is wrong, complain.
	unless ($assoc_data =~ /^\S+\sark:\/13030\/([a-z0-9]+)$/) {
		die "$c:  format of line \"$_\" from the output of command ",
			"\"$lhdrp_assoc_command\" was invalid, stopped";
		}

	# Save the ARK numbers in our hash.
	$muir_mets{$1} = 1;
	}
close(ASSOC);

# Say how many ARK numbers we found.
print "$c:  found ", scalar(keys %muir_mets), " ARK numbers for the Muir ",
	"Correspondence METS XML\n";

# Create a parser.
$parser = XML::LibXML->new( );

# Zero our counters.
$muir_mets_xml_files = 0;
$changed_muir_mets_xml_files = 0;

# Get the contents of the METS directory.
opendir(DIR, $input_dir) ||
	die "$c:  unable to open directory \"$input_dir\", $!, stopped";
@dir_contents = readdir(DIR);
closedir(DIR);

# Process the contents of the directory.
foreach $dir_entry (@dir_contents) {
	# Skip "." and ".." as a matter of course.
	next if ($dir_entry eq ".");
	next if ($dir_entry eq "..");

	# If this entry is not a file, skip it.
	next unless (-f "$input_dir/$dir_entry");

	# Skip it if it's not a METS XML file.
	next unless ($dir_entry =~ /^([a-z0-9]+).mets.xml$/);

	# Skip it if it's not a Muir Correspondence METS XML file.
	next unless (exists($muir_mets{$1}));

	# Count this file.
	$muir_mets_xml_files++;

	# Parse the file.
	eval {
		$document = $parser->parse_file("$input_dir/$dir_entry");
		};
	if (length($@) != 0) {
		die "$c:  unable to parse \"$input_dir/$dir_entry\", $@, ",
			"stopped";
		}

	# Look for the "<transcription>" elements.
	@nodes = $document->findnodes("//transcription");

	# If there aren't any, then we don't need to work on this file.
	next if (scalar(@nodes) == 0);

	# Indicate that we haven't fixed any "<transcription>" element yet.
	$transcription_fixed = 0;

	# Process each "<transcription>" element.
	foreach $node (@nodes) {
		# If there are any "<br>" children, then this "<transcription>"
		# has already been fixed, and we can move on.
		@children = $node->childNodes( );
		$has_br_child = 0;
		foreach (@children) {
			next unless ($_->nodeType( ) == XML_ELEMENT_NODE);
			if ($_->nodeName( ) eq "br") {
				$has_br_child = 1;
				last;
				}
			}

		# SKip this node if it doesn't need fixing (if it has a
		# "<br>" child).
		next if ($has_br_child);

		# Process the text nodes.
		foreach (@children) {
			next unless ($_->nodeType( ) == XML_TEXT_NODE);
			$text_content = $_->getData( );

			# If there were any " br " to change, do it and
			# record that fact.  (Yes, I know that "<<br/>>"
			# isn't valid.  I'm inserting that, so that I can
			# be sure I have found it later.)
			if ($text_content =~ s/\bbr\b/<<br\/>>/g) {
				$transcription_fixed = 1;
				$_->setData($text_content);
				}
			}
		}

	# If we didn't have to fix any of the "<transcription>" elements
	# in this METS XML file, move on to the next one.
	next unless ($transcription_fixed);

	# Write out the updated XML in a temporary file.
	$temp_file = "$input_dir/$dir_entry.new";
	$document->toFile($temp_file);

	# Unfortunately, "setData( )" encodes "<<br/>>" as
	# "&lt;&lt;br/&gt;&gt;".  So, we now copy the temp file file back
	# to the METS file, un-encoding it.
	open(IN, "<", $temp_file) ||
		die "$c:  unable to open \"$temp_file\" for input, $!, stopped";
	open(OUT, ">", "$input_dir/$dir_entry") ||
		die "$c:  unable to open \"$input_dir/$dir_entry\" for ",
			"output, $!, stopped";
	while(<IN>) {
		chomp;
		s/&lt;&lt;br\/&gt;&gt;/<br\/>/g;
		print OUT "$_\n";
		}
	close(OUT);
	close(IN);

	# Count the corrected METS file.
	$changed_muir_mets_xml_files++;

	# Delete the temporary file.
	unless (unlink($temp_file)) {
		die "$c:  unable to delte \"$temp_file\", $!, stopped";
		}
	}

# Report on the number of Muir Correspondence METS files we found,
# and the number that were fixed.
print "$c:  $muir_mets_xml_files METS files found for Muir Correspondence\n";
print "$c:  $changed_muir_mets_xml_files of those file(s) fixed\n";
