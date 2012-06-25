#! /usr/bin/perl

# ------------------------------------
#
# Project:	LSTA Muir Letters
#
# Name:		transform_muir_contentdm.pl
#
# Function:	Make changes to the supplied "contentdm" XML file for Muir
#		letters, prior to processing it with 7train.
#
# Command line parameters:
#
#		1 - required - the original Muir letters contentdm XML file.
#
#		2 - required - the changed Muir letters contentdm XML file.
#
#
# Author:	Michael A. Russell
#
# Revision History:
#		2008/7/1 - MAR - Initial writing
#		2009/7/2 - MAR - Tweak the "getimage.exe" parameters.
#		2009/8/18 - MAR - Change " br "s in "<pagetext>" to
#			"<br/>".
#		2009/8/18 - MAR - Remove the change of " br "s in
#			"<pagetext>" to "<br/>", because 7train removes
#			the "<br/>"s, so they don't make it into the
#			METS.  (Instead, we'll postprocess the
#			"<transcription>" elements in the METS.)
#		2009/9/1 - MAR - Reformat the URLs in the "<isPartOf>" elements.
#
# ------------------------------------

use strict;
use warnings;

# Pull in code we'll need
use XML::LibXML;

# Declare our variables.
use vars qw(
	$c
	@children
	$document
	$input_file
	$node
	@nodes
	$output_file
	$parser
	$pos
	$temp_file
	$text_content
	);

# Get the command name for the error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
undef $pos;

# Examine command line parameters.
unless (scalar(@ARGV) >= 2) {
	die "$c:  this script requires command line parameters that ",
		"specify the input file and the output file, stopped";
	}
$input_file = $ARGV[0];
$output_file = $ARGV[1];
if (scalar(@ARGV) > 2) {
	print STDERR "$c:  this script uses only 2 command line parameters - ",
		"all beyond that have been ignored\n";
	}

# Parse the input file.
$parser = XML::LibXML->new( );
eval {
	$document = $parser->parse_file($input_file);
	};
if (length($@) != 0) {
	die "$c:  unable to parse \"$input_file\", $@, stopped";
	}

# Transform JPG URLs.
@nodes = $document->findnodes("/metadata/record/structure/page/pagefile" .
	"[pagefiletype = 'access']/pagefilelocation");
foreach $node (@nodes) {
	# Get the text content of this "<pagefilelocation>".
	$text_content = $node->textContent( );

	# Make sure that it has a single child, which is a text node.
	@children = $node->childNodes( );
	unless (scalar(@children) == 1) {
		die "$c:  \"<pagefilelocation>\" with text content ",
			"\"$text_content\" has ", scalar(@children), " child ",
			"nodes, stopped";
		}
	unless ($children[0]->nodeType == XML_TEXT_NODE) {
		die "$c:  the singleton child of \"<pagefilelocation>\" with ",
			"text content \"$text_content\" is not a text node, ",
			"stopped";
		}

	# Reformat the text content.
	if ($text_content =~ /^(http:.*)showfile.exe(\?.+)$/) {
		$text_content = $1 . "getimage.exe" . $2 .
			"&DMSCALE=50&DMWIDTH=10000&DMHEIGHT=10000&" .
			"DMMODE=viewer&DMFULL=0";
		$children[0]->setData($text_content);
		}
	else {
		print STDERR "$c:  format of \"<pagefilelocation>\" text ",
			"content \"$text_content\" was not recognized - ",
			"leave it as is\n";
		}
	}

# Transform the URLs in the "<isPartOf>" elements.
@nodes = $document->findnodes("/metadata/record/isPartOf");
foreach $node (@nodes) {
	# Get the text content of this "<isPartOf>".
	$text_content = $node->textContent( );

	# Make sure that it has a single child, which is a text node.
	@children = $node->childNodes( );
	unless (scalar(@children) == 1) {
		die "$c:  \"<isPartOf>\" with text content \"$text_content\" ",
			"has ", scalar(@children), " child nodes, stopped";
		}
	unless ($children[0]->nodeType == XML_TEXT_NODE) {
		die "$c:  the singleton child of \"<isPartOf>\" with text ",
			"content \"$text_content\" is not a text node, stopped";
		}

	# Reformat the URL.
	$text_content =~ s|http://ark\.cdlib\.org/ark:/13030/kt0w1031nc|http://www.oac.cdlib.org/findaid/ark:/13030/kt0w1031nc|;
	$children[0]->setData($text_content);
	}

## Find the "<pagetext>" elements.
#@nodes = $document->findnodes("//pagetext");
#foreach $node (@nodes) {
#	# Get the text content of this "<pagetext>" element.
#	$text_content = $node->textContent( );
#
#	# Make sure that it has a single child, which is a text node.
#	@children = $node->childNodes( );
#	unless (scalar(@children) == 1) {
#		die "$c:  \"<pagetext>\" with text content \"$text_content\" ",
#			"has ", scalar(@children), " child nodes, stopped";
#		}
#	unless ($children[0]->nodeType == XML_TEXT_NODE) {
#		die "$c:  the singleton child of \"<pagetext>\" with text ",
#			"content \"$text_content\" is not a text node, stopped";
#		}
#
#	# Reformat the text content.
#	$text_content =~ s/\bbr\b/<<br\/>>/g;
#
#	# Put the reformatted text back into the text node.
#	$children[0]->setData($text_content);
#	}

# Write out the updated contentdm XML.
$document->toFile($output_file);

## Unfortunately, "setData( )" encodes "<br/>" as "&lt;br/&gt;".  So, we
## now copy the file, un-encoding it.  To be sure that we're only working
## on the ones we have added, change the ones we have added to "<<br/>>".
#$temp_file = "$output_file.new";
#open(IN, "<", $output_file) ||
#	die "$c:  unable to open \"$output_file\" for input, $!, stopped";
#open(OUT, ">", $temp_file) ||
#	die "$c:  unable to open \"$temp_file\" for output, $!, stopped";
#while(<IN>) {
#	chomp;
#	s/&lt;&lt;br\/&gt;&gt;/<br\/>/g;
#	print OUT "$_\n";
#	}
#close(OUT);
#close(IN);
#
## Rename the temporary file as the output file.
#unless (rename($temp_file, $output_file)) {
#	die "$c:  unable to rename \"$temp_file\" as \"$output_file\", ",
#		"$!, stopped";
#	}
