BEGIN {
	push @INC, "../lib/LibCDL";
}

# use strict;
use Data::Dumper;
use URI::Escape;
use BerkeleyDB;

use vars qw($forreal);
$forreal = 1;

use Getopt::Long;
$ret = GetOptions qw(--onefile+);

$ENV{OACDATA} = $ENV{OACDATA} || "/apps/dsc/data/in/oac-ead";


#$ENV{OACDATA} = "/voro/data/oac-ead";
use OacBatch;

$| = "1";


local $parser = XML::LibXML->new() || die ("$0: could not make new parser");


my @batch = <TEST>;

if ($opt_onefile) {

	do_it(@ARGV);

} else {


opendir (BASE, "$ENV{OACDATA}/prime2002") || die ("$! $_ $ENV{OACDATA}/prime2002");

#while ( my $subdir = readdir(BASE)) {
while ( my $subdir = readdir(BASE)) {
	next if ($subdir eq "." || $subdir eq ".." || $subdir eq "CVS");
	#print "subdir $subdir\n";
	opendir(SUB, "$ENV{OACDATA}/prime2002/$subdir") || die ("$ENV{OACDATA}/prime2002/$subdir $! $_");
	while (my $repdir = readdir(SUB)) {
		next if ($repdir eq "." || $repdir eq ".." || $repdir eq "CVS");
		#print "$repdir\n";
		if ($repdir =~ m,\.xml$,){
			do_it("$ENV{OACDATA}/prime2002/$subdir/$repdir");
		} else {
			opendir(REP, "$ENV{OACDATA}/prime2002/$subdir/$repdir") || die ("$ENV{OACDATA}/prime2002/$subdir/$repdir $! $_");
			while (my $file = readdir(REP)) {
				do_it("$ENV{OACDATA}/prime2002/$subdir/$repdir/$file") if ($file =~ m,\.xml$,);
			}
		}
	}
}

}

exit;

sub do_it {

		my ($match) = @_;
		#print $match;
		my($ids, $foo) = getpois($match);
		#print Dumper $ids;
	if ($opt_onefile) {
		my $n = 0;
		for (@{$ids}) {
			print "$_ ${$foo}[$n]\n";
			$n++;
		}
	} else {
		print join(" ",@{$ids}) , "\n" if (scalar @{$ids} > 1 );
	}
}


sub getpois {
	my ($file) = @_;
	if (-e $file) {
		my @return;
		my $doc;
        	if (!($doc = $parser->parse_file($file) ) ) {
               	 	print STDERR "$0: LibXML parse_file($file) failed";
                	return 0;
        	}
        	my $root = $doc->getDocumentElement;
		@pois = $doc->findnodes("/ead/archdesc//dao[starts-with(\@role,'http://oac.cdlib.org/arcrole/define')]/\@poi | /ead/archdesc//dao[starts-with(\@content-role,'http://oac.cdlib.org/arcrole/define')]/\@poi
| /ead/archdesc//daogrp[not(starts-with(\@content-role,'http://oac.cdlib.org/arcrole/link'))]/\@poi");
		#[starts-with(@arcrole,"http://oac.cdlib.org/arcrole/define")]/@poi
		($eadid) = $doc->findnodes('/ead/eadheader/eadid/@identifier');
		die ("$0: $file: no /ead/eadheader/eadid[\@type='CDL-POI']\n") unless $eadid;
		push @return, $eadid->textContent();
		push @file , $file;
		for my $d (@pois) {
			my $href = $d->findvalue(q{../@href | ../daoloc[@href][1]/@href}) | ""; 
			push @return, $d->nodeValue();
			push @file, $href; 

		}

		my @nopois = $doc->findnodes(q{/ead/archdesc//dao[not(@poi)] | /ead/archdesc//daogrp[not(@poi)]});
		for my $d (@nopois) {
			my $href = $d->findvalue(q{@href | daoloc[@href][1]/@href}) | ""; 
			push @return, "local";	
			push @file, uri_unescape($href);
		}

		return \@return, \@file ;
	} else {
		return 0;
	}
}
