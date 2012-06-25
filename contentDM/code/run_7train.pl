#! /cdlcommon/products/bin/perl

# ------------------------------------
#
# Project:	LSTA LHDRP
#
# Name:		run_7train.pl
#
# Function:	Run the "7train" XSL against a CONTENTdm export XML file.
#
# Command line parameters:
#
#		1 - required - the location of the input.  this can be either
#			a single XML file, or a directory.  if it is a
#			directory, then run "7train" against all the XML files
#			in the directory.
#
#		2 - optional - the location of the "Java home".  the default
#			(if this parameter is omitted or of length zero) is
#			the value of the environment variable JAVA_HOME, or,
#			if that is not set, "/usr".
#
#		3 - optional - the Saxon jar file.  the default is (if this
#			parameter is omitted or of length zero)
#			"classes/saxon8.jar" relative to the directory in
#			which this script is located.
#
#		4 - optional - the stylesheet.  the default (if this
#			parameter is omitted or of length zero) is
#			"../../7train/cdm.xsl" relative to the directory in
#			which this script is located.
#
#		5 - optional - the directory into which to write the output
#			METS XML files.  the default (if this parameter is
#			omitted or of length zero) is "../../mets" relative
#			to the directory in which this script is located.
#
#		6 - optional - the LHDRPassoc jar file.  the default is (if
#			this parameter is omitted or of length zero)
#			"classes/LHDRPassoc.jar" relative to the directory in
#			which this script is located.
#
#		7 - optional - the BerkeleyDB jar file.  the default is (if
#			this parameter is omitted or of length zero)
#			"classes/je-3.2.76/lib/je-3.2.76.jar" relative to
#			the directory in which this script is located.
#
#
# Author:	Michael A. Russell
#
# Revision History:
#		2008/7/9 - MAR - Initial writing
#		2008/7/11 - MAR - Changes necessary so that the XSLT could
#			do the local id lookups using the Java LHDRPassoc
#			class.
#		2008/7/18 - MAR - Stylesheet location fixed.
#
# ------------------------------------

use strict;
use warnings;

# Declare our variables.
use vars qw(
	$berkeleydb_jar
	$c
	@dir_contents
	$highest_exit_code
	$input_location
	$java_command
	$java_home
	$lhdrp_assoc_jar
	$nearby
	$output_directory
	$pos
	$saxon_jar
	$stylesheet
	@xml_files
	);

# Declare a subroutine that we'll define later.
sub process_file;

# Pull in code we'll need.
use Cwd 'abs_path';

# Get the command name for the error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "./";
undef $pos;

# Set the default values, which may be overridden by command line parameters.
if (exists($ENV{"JAVA_HOME"})) {
	$java_home = $ENV{"JAVA_HOME"};
	}
else {
	$java_home = "/usr";
	}
$saxon_jar = $nearby . "classes/saxon8.jar";
$stylesheet = $nearby . "../../7train/cdm.xsl";
$output_directory = $nearby . "../../mets";
$lhdrp_assoc_jar = $nearby . "classes/LHDRPassoc.jar";
$berkeleydb_jar = $nearby . "classes/je-3.2.76/lib/je-3.2.76.jar";

# Examine the command line parameters.
if ((scalar(@ARGV) < 1) || (length($ARGV[0]) == 0)) {
	die "$c:  the location of the input was not specified, stopped";
	}
$input_location = $ARGV[0];

if ((scalar(@ARGV) >= 2) && (length($ARGV[1]) != 0)) {
	$java_home = $ARGV[1];
	}

if ((scalar(@ARGV) >= 3) && (length($ARGV[2]) != 0)) {
	$saxon_jar = $ARGV[2];
	}

if ((scalar(@ARGV) >= 4) && (length($ARGV[3]) != 0)) {
	$stylesheet = $ARGV[3];
	}

if ((scalar(@ARGV) >= 5) && (length($ARGV[4]) != 0)) {
	$output_directory = $ARGV[4];
	}

if ((scalar(@ARGV) >= 6) && (length($ARGV[5]) != 0)) {
	$lhdrp_assoc_jar = $ARGV[5];
	}

if ((scalar(@ARGV) >= 7) && (length($ARGV[6]) != 0)) {
	$berkeleydb_jar = $ARGV[6];
	}

if (scalar(@ARGV) > 7) {
	print STDERR "$c:  this command uses only the first seven command ",
		"line parameters - the rest have been ignored\n";
	}

# Check that what we have been given is valid.
unless (-e $input_location) {
	die "$c:  the input location (\"$input_location\") does not exist, ",
		"stopped";
	}

unless (-e $java_home) {
	die "$c:  the Java home (\"$java_home\") does not exist, stopped";
	}
unless (-d _) {
	die "$c:  the Java home (\"$java_home\") is not a directory, stopped";
	}
$java_command = "$java_home/bin/java";
unless (-e $java_command) {
	die "$c:  inside the Java home (\"$java_home\"), \"$java_command\" ",
		"does not exist, stopped";
	}
unless (-x _) {
	die "$c:  inside the Java home (\"$java_home\"), \"$java_command\" ",
		"is not executable, stopped";
	}

unless (-e $saxon_jar) {
	die "$c:  the Saxon jar (\"$saxon_jar\") does not exist, stopped";
	}
unless (-f _) {
	die "$c:  the Saxon jar (\"$saxon_jar\") is not a file, stopped";
	}

unless (-e $stylesheet) {
	die "$c:  the stylesheet (\"$stylesheet\") does not exist, stopped";
	}
unless (-f _) {
	die "$c:  the stylesheet (\"$stylesheet\") is not a file, stopped";
	}

unless (-e $lhdrp_assoc_jar) {
	die "$c:  the LHDRPassoc jar (\"$lhdrp_assoc_jar\") does not exist, ",
		"stopped";
	}
unless (-f _) {
	die "$c:  the LHDRPassoc jar (\"$lhdrp_assoc_jar\") is not a file, ",
		"stopped";
	}

unless (-e $berkeleydb_jar) {
	die "$c:  the BerkeleyDB jar (\"$berkeleydb_jar\") does not exist, ",
		"stopped";
	}
unless (-f _) {
	die "$c:  the BerkeleyDB jar (\"$berkeleydb_jar\") is not a file, ",
		"stopped";
	}

# (Convert the output directory to an absolute path.)
$output_directory = abs_path($output_directory);
unless (-e $output_directory) {
	die "$c:  the output directory (\"$output_directory\") does not ",
		"exist, stopped";
	}
unless (-d _) {
	die "$c:  the output directory (\"$output_directory\") is not a ",
		"directory, stopped";
	}

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
		next unless (/\.xml$/);
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

# Exit with the highest exit code we encountered.
exit($highest_exit_code);

# -----
# Subroutine to process one file.
sub process_file {
	my $input_file = $_[0];

	my $be_silent;
	my $cmd;
	my $exit_code;
	my $i;
	my @output_lines;

	# Build the command we're going to run.  (Using the "-jar" option
	# apparently causes the "-cp" option to be ignored.  Therefore,
	# put the Saxon ".jar" file in the class path, and mention the
	# transform class name explicitly.)
	$cmd = "$java_command " .
		"-cp $saxon_jar:$lhdrp_assoc_jar:$berkeleydb_jar " .
		"net.sf.saxon.Transform " .
		"\"$input_file\" " .
		"\"$stylesheet\" " .
		"\"outputdir=$output_directory\" " .
		"2>&1";

	# Run the command.
	@output_lines = `$cmd`;

	# Get the exit code.
	$exit_code = $? >> 8;

	# Keep track of the highest exit code we have seen.
	if ($exit_code > $highest_exit_code) {
		$highest_exit_code = $exit_code;
		}

	# Riffle through the output lines.  If all is as expected, say
	# nothing.
	$be_silent = 0;
	if ((scalar(@output_lines) >= 2) &&
		($output_lines[0] eq "Finding record\n")) {
		$be_silent = 1;
		for ($i = 1; $i < scalar(@output_lines); $i++) {
			if ($output_lines[$i] !~ /^Outputting to: file:/) {
				$be_silent = 0;
				last;
				}
			}
		}
	return if ($be_silent);

	# Complain.
	print STDERR "$c:  unexpected output from command \"$cmd\" follows:\n";
	print STDERR @output_lines;
	return;
	}
