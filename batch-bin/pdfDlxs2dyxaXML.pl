#!/usr/bin/env perl
# 
# Take finished pdf directories and package them for voro.cdlib.org
$| = 0;

#use strict;
use Data::Dumper;
use File::Path;

use XML::LibXML;
use XML::LibXSLT;

# http://stackoverflow.com/questions/8563377/
use BSD::Resource qw(PRIO_PROCESS setpriority);

setpriority(
    PRIO_PROCESS,       # 1
    $$,
    19
);

my $pid = $$;
`ionice -c2 -p$pid`;

$eadroot = $ENV{OACDATA} || "$ENV{HOME}/data/in/oac-ead";
$dynaroot = $ENV{DYNROOT} || "$ENV{HOME}/data/xtf/data";

sub poi2pdf {
	#print Dumper @_;
        my $poi = shift;
        $poi =~ s,[.|/],,g;
        my $dir = substr($poi, -2);
        $poi =~ s|ark:13030(.*)|$dynaroot/13030/$dir/$1/files/$1.pdf|;
	my $part = $1;
                if (! -e "$dynaroot/13030/$dir/$part/files" ) {
                        mkpath("$dynaroot/13030/$dir/$part/files");
                }
        return "$poi";
}

sub poi2supplimental {
        my $poi = shift;
        $poi =~ s,[.|/],,g;
        my $dir = substr($poi, -2);
        $poi =~ s|ark:13030(.*)|$dynaroot/13030/$dir/$1/files/|;
        return "$poi";
}


use Getopt::Long;
$ret = GetOptions qw(--onefile+);

$| = "1";

local $parser = XML::LibXML->new() || die ("$0: could not make new parser");


if ($opt_onefile) {

	do_it(@ARGV);

} else {


opendir (BASE, "$eadroot/prime2002") || die ("$! $_ $eadroot/prime2002");

#while ( my $subdir = readdir(BASE)) {
while ( my $subdir = readdir(BASE)) {
	next if ($subdir eq "." || $subdir eq ".." || $subdir eq "CVS");
	#print "subdir $subdir\n";
	opendir(SUB, "$eadroot/prime2002/$subdir") || die ("$eadroot/prime2002/$subdir $! $_");
	while (my $repdir = readdir(SUB)) {
		next if ($repdir eq "." || $repdir eq ".." || $repdir eq "CVS");
		#print "$repdir\n";
		if ($repdir =~ m,\.xml$,){
			do_it("$eadroot/prime2002/$subdir/$repdir");
		} else {
			opendir(REP, "$eadroot/prime2002/$subdir/$repdir") || die ("$eadroot/prime2002/$subdir/$repdir $! $_");
			while (my $file = readdir(REP)) {
				do_it("$eadroot/prime2002/$subdir/$repdir/$file") if ($file =~ m,\.xml$,);
			}
		}
	}
}

}

exit;

sub do_it {
	my ($match) = @_;
	
	# the ead xml file in prime2002
	my $xml = $match;
        my $supplimental = $match;

	# the path to the generated PDF file
	$match =~ s,/prime2002/,/pdf/,;
	$match =~ s,\.xml$,.pdf,;

	my $ark = geteadid($xml);

	# the path to contributor supplied supplimental PDF files
	$supplimental =~ s,/prime2002/,/user-pdf/,;
	$supplimental =~ s,\.xml$,,;
	mkpath("$supplimental");
	my $file_dest = poi2supplimental($ark);

	opendir(SUPP, "$supplimental") || die ("$supplimental $! $_");
	while (my $file = readdir(SUPP)) {
		next if ($file eq "." || $file eq ".." || $file eq "CVS" || $file eq ".DAV");
		next if ($file =~ m,^\.,);
		if ( $file =~ m,\.pdf$,) {
			my $command = qq{/bin/cp -p "$supplimental/$file" $file_dest};
			print "$command\n";
			system($command);
			$command = qq{java -jar $ENV{HOME}/java/pdfbox/pdfbox-app.jar ExtractText -encoding UTF-8 "$file_dest/$file"};
			print "$command\n";
                        my $filepart = substr $file, 0, -4;
                        $command2 = qq{perl -pi -e 's/[[:cntrl:]]/ /g' "$file_dest/$filepart.txt"};
			print "$command2\n";
			system($command);
			system($command2);
		}
	}
        
}

sub geteadid {
        my ($file) = @_;
        if (-e $file) {
                my @return;
                my $doc;
                if (!($doc = $parser->parse_file($file) ) ) {
                        print STDERR "$0: LibXML parse_file($file) failed";
                        return 0;
                }
                my $root = $doc->getDocumentElement;
                ($eadid) = $doc->findnodes('/ead/eadheader/eadid/@identifier');
                return $eadid->textContent();
        } else {
                return 0;
        }
}


exit;
