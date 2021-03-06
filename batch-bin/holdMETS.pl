#!/usr/bin/env perl
# saxon /voro/out/thb5199n6zz/hb5199n6zz.mets.xml removedUp.xslt voroOut='yes'
#com.icl.saxon.StyleSheet

use File::Path;

my $removeXSLT = "/dsc/branches/production/voro/xslt/removedUp.xslt";
my $voroDel = "/dsc/data/xtf/" || $ENV{'VORODEL'};
#my $saxon = "java com.icl.saxon.StyleSheet";
my $saxon ="java -Xmx1024m -cp /dsc/branches/production/xtf/WEB-INF/lib/saxonb-8.9.jar -DentityExpansionLimit=1000000 net.sf.saxon.Transform";

my ($ark) = @ARGV;
#die "needs a 13030 ARK\n" unless ($ark =~ m,^ark:/13030/.*$,);

my ($ark2infile, $arkdir) = poi2filedir($ark);
my $ark2outfile = "$ark2infile.REMOVE";

open (INFILE,"<$ark2infile") || die("can't open datafile: $ark2infile $!");
my $beenDone;
while (<INFILE>) {
	if (m,PROFILE="http://ark.cdlib.org/ark:/13030/kt4199q42g",) {
		$beenDone = 'true';
		$! = 103;
		last;
	}
}
die "been done" if $beenDone;

my $transform = qq{$saxon -o $ark2outfile $ark2infile $removeXSLT voroOut='yes'};
print "$transform\n";
die "XSLT failed: $!" if (system($transform) != 0 );

my $mv1 = qq{cp -rp $ark2infile "$ark2infile.orig"};
print "$mv1\n";
die "cp failed: $!" if (system($mv1) != 0 );

my $mv2 = qq{mv $ark2outfile $ark2infile};
print "$mv2\n";
die "mv failed: $!" if (system($mv2) != 0 );

my $text_content = $ark2infile;
$text_content =~ s,\.mets\.xml$,.xml,;

if (-e $text_content) {
	my $touch = qq{touch $text_content};
	print "$touch\n";
	die "touch failed: $!" if (system($touch) != 0 );
}

# Remove associated files
my $filesDir = "$arkdir/files/";
if (-e $filesDir) {
    my $rmFiles = qq{rm -f $filesDir*};
    print "$rmFiles\n";
    die "remove of supplemental files failed: $!" if (system($rmFiles) != 0);
}


sub poi2filedir {
        my $poi = shift;
        $poi =~ s,[.|/],,g;
        my $dir = substr($poi, -2);
        $poi =~ m,ark:(\d\d\d\d\d)(.*),;
        my $bdir = $2 ;
        $poi = "$voroDel/data/$1/$dir/$bdir/$bdir.mets.xml";
        return ($poi, "$voroDel/data/$1/$dir/$bdir/");
}


