#package OacBatch;

use strict;
use Carp;
use vars qw($redo $forreal);
use XML::LibXML;
use XML::LibXML::Common qw(:encoding);

if (!$ENV{'OACDATA'}) { croak("OACDATA environmental variable not defined"); }
if (!$ENV{'PREFIX'}) { croak("PREFIX environmental variable not defined"); }

sub sgmlToXML {
	my ($in, $out) = @_;
	my $cmd = qq{sx.sh $in > $out};
	if ((-e $out) && (!$redo)) {
		# warn("$out exists; skipping");
		return 0;
	}
	if ($forreal) { 
		system($cmd) || carp("\n\n$cmd\n$0 $! $1");
	} else {
		print "$cmd\n";
	}
	return 1;
}

sub saxon {
	my ($xslt, $params, $in, $out) = @_;
	# my $cmd = qq{saxon.sh $in $xslt $params > $out};
	# java -mx120m -classpath $PREFIX/bin/saxon.jar com.icl.saxon.StyleSheet $1 $2 $3 $4 $5 $6 $7
	my $cmd = qq{java -mx120m -classpath $ENV{PREFIX}/bin/saxon.jar com.icl.saxon.StyleSheet -o $out $in $xslt $params};
	#print $cmd;
	if ((-e $out) && (!$redo)) {
		# warn("$out exists; skipping");
		return 0;
	}
	if ($forreal) { 
			      #  for some reason this always thinks
			      #  that it fails, but it really works
		system($cmd); #  || carp("\n\n$cmd\n$0 $! $1");
	} else {
		print "$cmd\n";
	}
	return 1;
}

sub xsltproc {
#  xsltproc("$ENV{'DLXSROOT'}/bin/xslt/cdlprime2objs.xsl", undef, $cdlprimeB, $objsB);
	my ($xslt, $params, $in, $out) = @_;
	my $cmd = qq{xsltproc $params $xslt $in > $out };
	if ((-e $out) && (!$redo)) {
		carp("$out exists; skipping");
		print STDERR ".";
		return 0;
	}
	if ($forreal) { 
		# print "\n$cmd\n";
		# print `which xsltproc`;
		system ($cmd); #  || carp("\n\n $cmd\n$0 $! $1");
	} else {
		print "$cmd\n";
	}
	return 1;
}

sub cdlToCdlprime {
        my ($infile, $outfile, $filetitle, $filenormal, $poi, @kids) = @_;
	if ((-e $outfile) && (!$redo)) {
		# carp("$outfile exists; skipping adding poi's and fixing titles");
		return 0;
	}
        open (OUTFILE, ">$outfile") || carp ("$0 $!: $outfile can't open for write");
        # print "$infile, $outfile, $filetitle, $filenormal\n";

        my $parser = XML::LibXML->new() || carp ("$0 $!: could not make new parser");
        my $doc;
        if (!($doc = $parser->parse_file($infile) ) ) { 
                print STDERR "$0 $!: LibXML parse_file($infile) failed"; 
                next; 
        }

        # print "$infile $doc\n";

        my $root = $doc->getDocumentElement;

        # get the eadheader and add a new <eadid>       
        #
        (my $eadheader) = $root->findnodes('/ead/eadheader');
        (my $eadid) = $root->findnodes('/ead/eadheader/eadid[1]');
        my ($cdltitle) = $root->findnodes('/ead/CDLTITLE[1]');
        my $cdlpath = $root->findvalue('/ead/CDLPATH[1]');
        # print "- $cdlpath\n";
        my $newid = $doc->createElement('eadid');
        $newid->setAttribute('type', 'CDL-POI' );

        # are my initials used??
        my $text = XML::LibXML::Text->new("$poi");
        # my $text = XML::LibXML::Text->new("ark:/" );
        $newid->appendChild($text);
        $eadheader->insertAfter($newid, $eadid) || carp("$0 $! $infile $poi");
        
        # change the <CDLTITLE> and add <NTITLE>
        #       
        my $newtitle = $doc->createElement('CDLTITLE');
        my $normal = $doc->createElement('NTITLE');
        my $newtitleT = XML::LibXML::Text->new(encodeToUTF8("iso-8859-1",$filetitle));
        my $normalT = XML::LibXML::Text->new(encodeToUTF8("iso-8859-1",$filenormal));
        $newtitle->appendChild($newtitleT);
        $normal->appendChild($normalT);
        $root->insertAfter($normal, $cdltitle);
        $root->replaceChild($newtitle, $cdltitle) ;
                        # unless ($cdltitle->getData ne "[no ?filetitle]");
        
        # assign IDs to DAOs
        #
        my $count = 0;
        for my $dao ($root->findnodes('/ead/archdesc//dao | /ead/archdesc//daogrp')) {
		#my $href = $dao->findvalue(.//@href);
		#print $href;
                $dao->setAttribute('poi', $kids[$count]);
                $count++;
        }
        
        print OUTFILE $doc->toString;
	close OUTFILE;
	# print `breaks.pl $outfile`;
}


sub sgmlP {
	my ($file, $root) = @_;
	$root = $ENV{'OACDATA'} unless $root;
	$file = "$root/sgml/$file";
	$file =~ s,.xml$,.sgm,;
	return $file;
}

sub xmlP {
	my ($file, $root) = @_;
	$root = $ENV{'OACDATA'} unless $root;
	$file = "$root/xml/$file";
	$file =~ s,.sgm$,.xml,;
	return $file;
}

sub cdlP {
	my ($file, $root) = @_;
	$root = $ENV{'OACDATA'} unless $root;
	$file =~ s,.sgm$,.xml,;
	$file = "$root/cdl/$file";
	return $file;
}

sub cdlprimeP {
	my ($file, $root) = @_;
	$root = $ENV{'OACDATA'} unless $root;
	$file =~ s,.sgm$,.xml,;
	$file = "$root/cdlprime/$file";
	return $file;
}

sub objsP {
	my ($file, $root) = @_;
	$root = $ENV{'OACDATA'} unless $root;
	$file =~ s,.sgm$,.xml,;
	$file = "$root/objs/$file";
	return $file;
}

sub mkdirs {

my @composites = qw (berkeley/bancroft/agi
	ucla/mss/olympics ucla/mss/neutra ucla/mss/bradley ucla/mss/latimes
	ucla/mss/zeitlinj ucla/mss/fultz ucla/arts/wlantz ucla/arts/gelbart
	ucla/arts/renoir ucla/biomed/bonica ucla/uarc/piotapes);

my @subatches = qw(xml cdl cdlprime objs) ;

my @subdirs = qw( bampfa chs caltech csa csl cspr csrml csuci chico csudh
    csudh/spcoll csudh/uarc csuf cmbs cuc fowler fcchs glhs getty gtu 
	grunwald hssa hcnc hoover humboldt huntington huntington/mss
	huntington/parc huntington/preph janm larc mills omca narc phm
	samcc maritime sfpl sdsu sdsu/spcoll sdsu/uarc sjcmus scu
	sonoma scl stanford stanford/mss stanford/rbd stanford/uarc
	berkeley berkeley/bancroft berkeley/ceda berkeley/esl
	berkeley/hdtl berkeley/igsl berkeley/mop berkeley/music
	berkeley/hearst berkeley/uarc berkeley/wrca ucdavis uci uci/cta
	uci/sea uci/spcoll uci/uarc ucla ucla/mss ucla/clark ucla/music
	ucla/arts ucla/biomed ucla/uarc ucr ucrmp ucsd ucsd/spcoll
	ucsd/scripps ucsf ucsf/spcoll ucsf/tcarc ucsf/uarc ucsb ucsc
	uidl usc usc/rhc usc/spcoll uop wjhc calher);


   for my $filetype ( @subatches ) {
	system("mkdir $ENV{'OACDATA'}/$filetype"); # || carp ("$0 $!");
	for my $cdlpath ( @subdirs ) {
		system("mkdir $ENV{'OACDATA'}/$filetype/$cdlpath");
			# || carp ("$0 $! $filetype $cdlpath");
	}
   }

}

return 1;
