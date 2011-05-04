#! /usr/bin/perl

# ------------------------------------
#
# Project:	OAC / Calisphere
#
# Name:		add.c-order.attributes.pl
#
# Function:	To add "score" and "C-ORDER" attributes to finding aids.
#
# Command line parameters:
#		1 - required - the name of the input.  it can be either the
#			name of the directory structure that contains the
#			finding aids, or the name of a file that contains one
#			finding aid.  (the finding aid files will be
#			rewritten when they are updated.)
#
# Author:	Michael A. Russell
#
# Revision History:
#		2009/4/6 - MAR - Initial writing
#		2009/4/8 - MAR - Add a "MAX-C-ORDER" attribute on the first
#			element that gets changed.  Allow the command line
#			parameter to be a file or a directory.
#		2009/4/21 - MAR - It would be better if the updated finding
#			aid were not written over the old one, but written
#			next to the old one, and then renamed when that was
#			complete.  (A crash during the writing of the upated
#			finding aid would result in lost data.)
#
# ------------------------------------

use strict;
use warnings;

# Declare our variable names.
use vars qw(
	$c
	$input_item
	$is_dir
	$parser
	$pos
	%score_for_c_s
	%score_for_dsc
	);

# Declare subroutines we'll define later.
sub process_dir;
sub process_file;

# Pull in code we'll need.
use XML::LibXML;

# Set the list of immediate child node names for "<dsc>" that contribute
# to its "score".
%score_for_dsc = (
	"address" => 1,
	"blockquote" => 1,
	"chronlist" => 1,
	"dsc" => 1,
	"head" => 1,
	"list" => 1,
	"note" => 1,
	"p" => 1,
	"table" => 1,
	"thead" => 1
	);

# Set the list of immediate child node names for "<c>" and "<c01>" through 
# "<c012", that contribute to its "score".
%score_for_c_s = (
	"accessrestrict" => 1,
	"accruals" => 1,
	"acqinfo" => 1,
	"altformavail" => 1,
	"appraisal" => 1,
	"arrangement" => 1,
	"bibliography" => 1,
	"bioghist" => 1,
	"controlaccess" => 1,
	"custodhist" => 1,
	"dao" => 1,
	"daogrp" => 1,
	"descgrp" => 1,
	"did" => 1,
	"fileplan" => 1,
	"head" => 1,
	"index" => 1,
	"note" => 1,
	"odd" => 1,
	"originalsloc" => 1,
	"otherfindaid" => 1,
	"phystech" => 1,
	"prefercite" => 1,
	"processinfo" => 1,
	"relatedmaterial" => 1,
	"scopecontent" => 1,
	"separatedmaterial" => 1,
	"thead" => 1,
	"userestrict" => 1
	);

# Get the command name for error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
#$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "";
#$nearby = "./" if ($nearby eq "");
undef $pos;

# Examine command line parameters.
if ((scalar(@ARGV) >= 1) && (length($ARGV[0]) > 0)) {
	$input_item = $ARGV[0];
	}
else {
	die "$c:  input directory was not specified, stopped";
	}
unless (-e $input_item) {
	die "$c:  \"$input_item\" does not exist, stopped";
	}
if (-d _) {
	$is_dir = 1;
	}
elsif (-f _) {
	$is_dir = 0;
	}
else {
	die "$c:  \"$input_item\" is neither a file nor a directory, stopped";
	}
if (scalar(@ARGV) > 1) {
	print STDERR "$c:  this script uses only one command line parameter - ",
		"all beyond that have been ignored\n";
	}

# Create a parser outside the loop.
$parser = XML::LibXML->new( );

# If the input is a file, just process one file.  If it's a directory,
# process the whole directory.
if ($is_dir) {
	process_dir($input_item);
	}
else {
	process_file($input_item);
	}

# -----
# Subroutine to process a directory.
sub process_dir {
	my $the_dir = $_[0];

	my @dir_contents;
	my $dir_entry;
	my @subdirs;

	# Read in the contents of the directory.
	opendir(DIR, $the_dir) ||
		die "$c:  unable to open directory \"$the_dir\", $!, stopped";
	@dir_contents = readdir(DIR);
	closedir(DIR);

	# Process the directory's contents.
	@subdirs = ( );
	foreach $dir_entry (@dir_contents) {
		# Ignore "." and ".." as a matter of course.
		next if ($dir_entry eq ".");
		next if ($dir_entry eq "..");

		# If it's a symlink, complain, and ignore it.
		if (-l "$the_dir/$dir_entry") {
			print STDERR "$c:  ignoring symbolic link ",
				"\"$the_dir/$dir_entry\"\n";
			next;
			}

		# If it's a directory, save it away.
		if (-d "$the_dir/$dir_entry") {
			push @subdirs, "$the_dir/$dir_entry";
			next;
			}

		# If it wasn't a file, complain, and ignore it.
		unless (-f _) {
			print STDERR "$c:  neither dir nor file ",
				"\"$the_dir/$dir_entry\" - ignoring it\n";
			next;
			}

		# If it wasn't an XML file, complain, and ignore it.
		unless ($dir_entry =~ /\.xml$/) {
			print STDERR "$c:  not an XML file ",
				"\"$the_dir/$dir_entry\" - ignoring it\n";
			next;
			}

		# Process the XML finding aid.
		process_file("$the_dir/$dir_entry");
		}

	# If there were any subdirectories, process them now.
	foreach (@subdirs) {
		process_dir($_);
		}
	}

# -----
# Subroutine to process a file.
sub process_file {
	my $the_file = $_[0];

	my $c_order;
	my $c_order_attrib;
	my $finding_aid;
	my $max_c_order;
	my $modified;
	my $node;
	my @nodes;
	my $score;
	my $score_hash;

	# Parse the finding aid.
	eval {
		$finding_aid = $parser->parse_file($the_file);
		};
	if (length($@) != 0) {
		die "$c:  unable to parse \"$the_file\", $@, stopped";
		}

	# Indicate that we have not modified the finding aid.  Yet.
	$modified = 0;

	# Prepare to calculate the maximum value of "C-ORDER".
	$max_c_order = -1;

	# Find all the nodes of interest.
	@nodes = $finding_aid->findnodes("//*[local-name(.) = 'dsc' or " .
		"local-name(.) = 'dscgrp' or local-name(.) = 'c' or " .
		"local-name(.) = 'c01' or local-name(.) = 'c02' or " .
		"local-name(.) = 'c03' or local-name(.) = 'c04' or " .
		"local-name(.) = 'c05' or local-name(.) = 'c06' or " .
		"local-name(.) = 'c07' or local-name(.) = 'c08' or " .
		"local-name(.) = 'c09' or local-name(.) = 'c10' or " .
		"local-name(.) = 'c11' or local-name(.) = 'c12']");

	# Add "score" attributes to the nodes, if they don't already have
	# one.
	foreach $node (@nodes) {
#		# Get the "score" attribute.
#		$score = $node->getAttribute("score");
#		if (defined($score)) {
#			# If we have a "score" attribute, and its value
#			# is numeric, don't do anything more with this
#			# one.
#			next if ($score =~ /^\d+$/);
#			die "$c:  element \"", $node->nodeName( ), "\" in ",
#				"\"$the_file\" already has a \"score\" ",
#				"attribute with value \"$score\" but it is ",
#				"not numeric, stopped";
#			}

		# Figure out what the "score" should be for this node.
		if ($node->nodeName( ) eq "dscgrp") {
			$score = 1;
			}
		else {
			if ($node->nodeName( ) eq "dsc") {
				# Identify the hash to use to calculate
				# the score for "<dsc>">.
				$score_hash = \%score_for_dsc;
				}
			else {
				# Identify the hash to use to calculate
				# the core for "<c>" and "<c01>" through
				# "<c12>" (i.e., for the rest).
				$score_hash = \%score_for_c_s;
				}

			# Count the immediate children of this node that
			# are in the list for this type of node.
			$score = 0;
			foreach ($node->childNodes( )) {
				if (exists($$score_hash{$_->nodeName( )})) {
					$score++;
					}
				}
			}

		# Install the new attribute.
		$node->setAttribute("score", $score);

		# Indicate that we have modified the finding aid.
		$modified = 1;
		}

	# Calculate the values for the "C-ORDER" attributes, and add them.
	$c_order = 1;
	foreach $node (@nodes) {
#		# Get the "C-ORDER" attribute.
#		$c_order_attrib = $node->getAttribute("C-ORDER");
#		if (defined($c_order_attrib)) {
#			# If we have a "C-ORDER" attribute, and its value
#			# is numeric, don't do anything more with this
#			# one.
#			next if ($c_order_attrib =~ /^\d+$/);
#			die "$c:  element \"", $node->nodeName( ), "\" in ",
#				"\"$the_file\" already has a \"C-ORDER\" ",
#				"attribute with value \"$c_order_attrib\" but ",
#				"it is not numeric, stopped";
#			}

		# Assign this value as the attribute.
		$node->setAttribute("C-ORDER", $c_order);

		# If this "C-ORDER" is larger than the largest such value
		# we have already seen, then this becomes the largest.
		if ($c_order > $max_c_order) {
			$max_c_order = $c_order;
			}

		# Add in the "score" of this node for the next node.
		$score = $node->getAttribute("score");
		$c_order += $score;

		# Indicate we have modified this finding aid.
		$modified = 1;
		}

	# If we have a maximum value for "C-ORDER" and a node to put it
	# on, do so now.
	if (($max_c_order > 0) && (scalar(@nodes) > 0)) {
		$nodes[0]->setAttribute("MAX-C-ORDER", $max_c_order);
		$modified = 1;
		}

	# If we haven't modified this finding aid, skip its rewrite.
	return unless ($modified);

	# Write the finding aid out.
	$finding_aid->toFile($the_file . ".new");

	# Rename the new file to the name of the old one.
	unless (rename($the_file . ".new", $the_file)) {
		die "$c:  unable to rename \"$the_file.new\" as ",
			"\"$the_file\", $!, stopped";
		}
	}
