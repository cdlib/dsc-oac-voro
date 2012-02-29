#!/usr/bin/env perl
#
use File::List;
use CGI;
use CGI::Carp qw(fatalsToBrowser) ;

use HTML::Template;
use BerkeleyDB ;
use Fcntl;
use MLDBM qw(DB_File Storable) ;
use Data::Dumper;
use HTML::Entities ();

my $ok_chars = 'a-zA-Z0-9-_\/\.';

my $cgi = new CGI;

foreach $param_name ( $cgi->param() ) {
    $_ = HTML::Entities::decode( $cgi->param($param_name) );
    $_ =~ s/[^$ok_chars]//go;
    $cgi->param($param_name,$_);
}


$filename = "/apps/dsc/users/apache/test.user.bdb";

#!!!! this needs to be set to workspace !!!!! for black hole!!!!
$dataroot = "/apps/dsc/workspace/test-oac/submission";
$templatef = "blackhole.tmpl";
my $status = 0;


my $db = tie (%users, "MLDBM", "$filename", O_RDONLY, 0644 )|| die ("$! $_");

my $ruser = $ENV{REMOTE_USER};
my $user = $users{$ruser};
if (!$user ) { 
	croak ( qq{user "$ruser" not found in database $filename}); 
	exit;
}

print "Content-type: text/html\n\n";
my $dir = getDir($user->{dir}, $cgi->param('subdir') );

#print "|$dir|";
#print "<preprocess>"; print Dumper $cgi; print Dumper %ENV;


## main branch in the code POST runs on a file; GET for directories	
if ($ENV{'REQUEST_METHOD'} eq 'POST') { &do_post; } else { &do_get; } 

		
sub do_post {
	my $file = $cgi->param('file');
	$file =~ s,^sgml/,,;
	my $header = getHeader($templatef);
print <<EOF;
$header
<h1><em>voro</em>EAD Testing: Processing Results</h1>
EOF

print "<p>" . `/usr/bin/date` . "</p>";

print <<EOF;
<p>Validating file for compliance with the EAD DTD, EAD XSD schema, and <em>OAC Best Practice Guidelines 
  for EAD</em>. Please be patient with large files. To keep a log of validation 
  messages, or as a receipt, save or print a copy of this web page. </p>
<p>Please report problems with <em>voro</em>EAD by sending us an email to: <a href="mailto:oacops\@cdlib.org">oacops\@cdlib.org</a>. 
Copy and paste the entire text of this Web page into your message when reporting a problem.</p>
<pre><font size=2>
EOF
	my $initial_root = $dataroot;
        $dataroot =~ s,submission,at2oac,; 
        print "$file\n";
	my $lint_command = "xmllint --noout $initial_root/$file 2>&1";


	print `$lint_command`;
        print `xsltproc -o $dataroot/$file /apps/dsc/branches/production/at2oac/at2oac.xsl $initial_root/$file`;
	my $exit = $? >> 8;
        $status = $exit;

	my $dtdvalidate_command = "xmllint --noout --dtdvalid http://oac.cdlib.org/ents/ead.dtd $dataroot/$file 2>&1";


	#$ENV{PREFIX} = "/voro/local";
	#print "$validate_command\n<br>";
	print `$dtdvalidate_command`;
	$exit = $? >> 8;
	print "\n 
        </pre><br>";

	$status = $status + $exit;
	print "</font>";

	if ($status != 0) {
print <<EOF;
<h2>File rejected by <em>voro</em>EAD due to errors.</h2>
<h3>Please correct the errors and reprocess the file.</h3>

EOF
#print "exit code $exit (# of errors from BPG/status.pl)";
		} 

	else {
print <<EOF;

<h2>File successfully processed by <em>voro</em>EAD</h2>
 
<a href="http://$ENV{FINDAID_HOSTNAME}/view?docId=ead-preview&doc.view=entire_text&source=http://$ENV{SERVER_NAME}/test-at2oac/$file"><h2>Preview</h2></a>

EOF
	}
print <<EOF;
</div>
<hr>
<div class="footer"><b>Questions? Contact us at: </b><a href="mailto:oacops\@cdlib.org">oacops\@cdlib.org</a>
</div>
</div>
<br>
</body>
</html>

EOF


}

sub do_get {
		my $template = HTML::Template->new(filename => $templatef);

		my $isdir;

		my @listing;
		#print "1: $dir <br>";
		if ($dir eq "/") {
			$checkdir = "$dataroot"; 
		} else {
			$checkdir = "$dataroot$dir";
		}
		#print "2: $checkdir <br>";
		my $search = new File::List("$checkdir");
		$search->show_only_dirs();
		my $dirs = $search->find;
		#print "3: " . Dumper $dirs ; 
			## toggle search option
			$search->show_only_dirs();
			my $sgmlfiles = $search->find("\.sgm\$");
			my $xmlfiles = $search->find("\.xml\$");
			my $a =  scalar @{$sgmlfiles};
			my $b = scalar @{$xmlfiles};
			my $c = $a + $b;
	
		if (scalar @{$dirs} > 2) {
			$listing = dirlist($dirs);
			$isdir = 1;
			#print Dumper $listing;
			#print "3A";
		} 
		#print "|$dir|";
		if ( $c > 0  && ($dir ne "/")) {
			#print Dumper $search;
			$listing =  filelist($listing, $sgmlfiles, $xmlfiles);
			$isdir = 0;
			#print "3B";
		}
#print $isdir;
#print Dumper $listing;
$template->param(USER_NAME => $user->{name});
$template->param(LISTING => $listing ) if $listing;
$template->param(ISDIR => $isdir);


print $template->output();

}

sub dirlist {
	my @return;
	my @list;
	my ($dirs) = @_;
	for (@{$dirs}) {
		next if ($_ =~ m,/CVS/$,);
		my $ret = $_;
		$ret =~ s,^$dataroot,,;
		push @list, $ret;
	}
	@list = sort @list;
	for (@list) {
		next if ($_ eq '' || $_ eq '/');
		my $testit = $_;
		$testit =~ s,$dir/,,;
		next unless($testit);
		my $item = qq{<a href="$ENV{SCRIPT_NAME}?subdir=$_">$_</a>};
		push @return, { 'item' => $item};
	}
	#print Dumper @return;
	return \@return;
}

sub filelist {
	my ($listing, $sgml, $xml) =  @_;
	my @return = @{$listing};
	my @list;
	for (@{$sgml}) {
		my $ret = $_;
        $ret =~ s,^$dataroot,,;
        push @list, $ret;
	}
	for (@{$xml}) {
		my $ret = $_;
        $ret =~ s,^$dataroot,,;
        push @list, $ret;
	}
	@list = sort(@list);
	for (@list) {
		my $item = $_;
		$item =~ s,//,/,g;
		$item = qq{<input name="file" type="radio" value="sgml$item">xml$item</input>};
		push @return, { 'item'=> $item};
	}
	return \@return;
}


sub getDir {
	my ($defaultdir, $askdir) = @_;
	$askdir =~ s/\.|\;|\<|\>|\?|\n|\f|\r|\\|\|//gi;
	$askdir =~ s,^/*,,g;
	$askdir =~ s,/*$,,g;
	if ($askdir) {
		if ($defaultdir eq "") {
			return "/$askdir";
		} elsif ($askdir =~ m,$defaultdir,) {
			return "/$askdir";
		} else {
			#die("$askdir is not a subdir of $defaultdir");
			return "/$askdir";
		}
	} else {
		return "/$defaultdir";	
	}
}

sub getHeader
{
	my ($infile) = @_;
	my $outbuf = '';
	open (IN, $infile) or die "Unable to open input: $infile\n";
	while ($line = <IN>) {
		chomp($line);
                last if ($line =~ /<h1>/i);
		$outbuf .= "$line\n";
	}
	close (IN);
	return $outbuf;
}

