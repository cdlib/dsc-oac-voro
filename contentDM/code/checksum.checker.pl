#! /usr/bin/env perl

# ------------------------------------
#
# Project:	LSTA LHDRP
#
# Name:		checksum.checker.pl
#
# Function:	The image files we receive from Northern Micrographics have
#		"checksum.fil" files that contain "SHA1" checksums of the
#		files.  This script recalculates the "SHA1" checksums, and
#		compares them with what's recorded in the "checksum.fil"
#		files in an attempt to detect any data corruption.
#
# Note:		This will likely be run on the machine used to stage the
#		image files, not on "voro.cdlib.org", but it is included
#		here, so it with other LSTA LHDRP scripts.
#
# Command line parameters:
#
#		1 - required - the location of the Northern Micrographics
#			data.  (this is a directory which will have
#			subdirectories by the names of the MARC institution
#			codes of the contributors.)
#
# Author:	Michael A. Russell
#
# Revision History:
#		2008/8/11 - MAR - Polished up for inclusion here.
#		2008/2/15 - MAR - Initial writing on "ingest1.cdlib.org".
#		2009/8/13 - MAR - Ignore things in the top level directory
#			that are not directories.
#
# ------------------------------------

use strict;
use warnings;

# Declare our variables.
use vars qw(
	$c
	$checksum
	$checksums_checked
	$cmd
	$exit_code
	@main_dir_contents
	$main_dir_entry
	$i
	$image_file
	$input_dir
	$line_no
	$nearby
	$pos
	$sha1sum_cmd
	@sha1sum_output
	%stored_checksum
	$stored_checksum_file
	@subdir_contents
	$subdir_entry
	@to_process
	);

# Get the command name for the error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
#$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "./";
undef $pos;

# Zero counter.
$checksums_checked = 0;

# Check the command line parameter.
if ((scalar(@ARGV) >= 1) && (length($ARGV[0]) != 0)) {
	$input_dir = $ARGV[0];
	}
else {
	die "$c:  the input directory was not specified, stopped";
	}

# Make sure we have access to the "sha1sum" command.
undef $sha1sum_cmd;
foreach (split(/:/, $ENV{"PATH"})) {
	if ((-x "$_/sha1sum") && (! defined($sha1sum_cmd))) {
		$sha1sum_cmd = "$_/sha1sum";
		}
	}
unless (defined($sha1sum_cmd)) {
	die "$c:  the \"sha1sum\" command is not accessible via \$PATH, ",
		"stopped";
	}

# Retrieve the list of contributor subdirectories.
opendir(DIR, $input_dir) ||
	die "$c:  unable to open directory \"$input_dir\", $!, stopped";
@main_dir_contents = readdir(DIR);
closedir(DIR);

# Make sure that the main directory contains what it should.
@to_process = ( );
MAIN_DIR_ENTRY:
foreach $main_dir_entry (@main_dir_contents) {
	# Ignore "." and "..".
	next if ($main_dir_entry eq ".");
	next if ($main_dir_entry eq "..");

	# Ignore anything that is not a directory.
	if (-l "$input_dir/$main_dir_entry") {
		print STDERR "$c:  ignoring symbolic link ",
			"\"$input_dir/$main_dir_entry\"\n";
		next;
		}
	unless (-d "$input_dir/$main_dir_entry") {
		print STDERR "$c:  ignoring \"$input_dir/$main_dir_entry\" ",
			"because it is not a directory\n";
		next;
		}

	# The only subdirectories should be contributor subdirs, and they
	# should all contain "gif", "jpeg", "jpeg_l", and "tiff" subdirectories.
	foreach $subdir_entry ("gif", "jpeg", "jpeg_l", "tiff") {
		unless (-e "$input_dir/$main_dir_entry/$subdir_entry") {
			print STDERR "$c:  \"$input_dir/$main_dir_entry/",
				"$subdir_entry\" does not exist - skipping ",
				"the processing of \"$input_dir/",
				"$main_dir_entry\"\n";
			next MAIN_DIR_ENTRY;
			}
		unless (-d _) {
			print STDERR "$c:  \"$input_dir/$main_dir_entry/",
				"$subdir_entry\" is not a directory - ",
				"skipping the processing of \"$input_dir/",
				"$main_dir_entry\"\n";
			next MAIN_DIR_ENTRY;
			}
		}

	# This contributor directory contains what we need.  Warn about
	# stuff that it contains that we won't examine.
	opendir(DIR, "$input_dir/$main_dir_entry") ||
		die "$c:  unable to open directory \"$input_dir/",
			"$main_dir_entry\", $!, stopped";
	@subdir_contents = readdir(DIR);
	close(DIR);

	# Look for something we won't use.
	foreach $subdir_entry (@subdir_contents) {
		# Ignore "." and "..".
		next if ($subdir_entry eq ".");
		next if ($subdir_entry eq "..");

		# Skip what we know is there.
		next if ($subdir_entry eq "gif");
		next if ($subdir_entry eq "jpeg");
		next if ($subdir_entry eq "jpeg_l");
		next if ($subdir_entry eq "tiff");

		# Complain about this extra thing.
		print STDERR "$c:  ignoring \"$input_dir/$main_dir_entry/",
			"$subdir_entry\"\n";
		}
	undef @subdir_contents;

	# Process each of the four subdirectories we need.
	foreach $subdir_entry ("gif", "jpeg", "jpeg_l", "tiff") {

		# Load the contents of the "checksum.fil" in it.
		$stored_checksum_file = "$input_dir/$main_dir_entry/" .
			"$subdir_entry/checksum.fil";
		open(CKSUMFIL, "<", $stored_checksum_file) ||
			die "$c:  unable to open \"$stored_checksum_file\" ",
				"for input, $!, stopped";
		%stored_checksum = ( );
		$line_no = 0;
		while(<CKSUMFIL>) {
			chomp;
			$line_no++;
			unless (/^SHA1 \(([A-Z0-9a-z_.]+)\) = ([A-F0-9]{40})/) {
				print STDERR "$c:  format of line $line_no in ",
					"\"$stored_checksum_file\" (\"$_\") ",
					"is invalid - ignoring it\n";
				next;
				}
			$stored_checksum{$1} = $2;
			}
		close(CKSUMFIL);

		# Run the "sha1sum" command on the files in the directory in
		# question.
		$cmd = "cd $input_dir/$main_dir_entry/$subdir_entry ; " .
			"$sha1sum_cmd * 2>&1";
		@sha1sum_output = `$cmd`;
		$exit_code = $? >> 8;
		if ($exit_code != 0) {
			die "$c:  command \"$cmd\" terminated with exit ",
				"code $exit_code, stopped";
			}

		# Walk through the command's output.
		for ($i = 0; $i < scalar(@sha1sum_output); $i++) {
			chomp($sha1sum_output[$i]);
			unless ($sha1sum_output[$i] =~
				/^([a-f0-9]{40})\s+(\S+)$/) {
				print STDERR "$c:  format of line ", ($i + 1),
					" of the output of command \"$cmd\" ",
					"(\"$sha1sum_output[$i]\") is invalid ",
					"- ignoring it\n";
				next;
				}
			$checksum = uc($1);
			$image_file = $2;

			# If this was the info about "checksum.fil", we can
			# ignore it.
			next if ($image_file eq "checksum.fil");

			# Make sure we have a stored checksum for this image
			# file.
			unless (exists($stored_checksum{$image_file})) {
				print STDERR "$c:  found no stored checksum ",
					"for image file \"$input_dir/",
					"$main_dir_entry/$subdir_entry/",
					"$image_file\"\n";
				next;
				}

			# Check the calculated checksum againsted the
			# stored checksum.
			if ($checksum ne $stored_checksum{$image_file}) {
				print STDERR "$c:  for image file ",
					"\"$input_dir/$main_dir_entry/",
					"$subdir_entry/$image_file\" the ",
					"stored checksum (\"",
					"$stored_checksum{$image_file}\") ",
					"does not match the calculated ",
					"checksum (\"$checksum\")\n";
				}

			# It has been checked, so remove it from the hash.
			delete $stored_checksum{$image_file};

			# It has been checked (perhaps not succcessfully),
			# so count it.
			$checksums_checked++;
			}

		# See if there were any stored checksums we didn't need.
		if (scalar(keys %stored_checksum) != 0) {
			print STDERR "$c:  there were stored checksums for ",
				"the following non-existent image files in ",
				"\"$input_dir/$main_dir_entry/",
				"$subdir_entry\":\n";
			foreach (sort keys %stored_checksum) {
				print STDERR "\t\"$_\"\n";
				}
			}
		}
	}

# Print count of checksums that were checked.
print "$c:  $checksums_checked checksums checked\n";
