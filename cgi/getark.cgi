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


$filename = "/apps/dsc/users/apache/test.user.bdb";
$oacdata = "/apps/dsc/data/in/oac-ead";
$dataroot = "$oacdata/prime2002";
$templatef = "getark.tmpl";
my $status = 0;


my $db = tie (%users, "MLDBM", "$filename", O_RDONLY, 0644 )|| die ("$! $_");

my $cgi = new CGI;

my $ruser = $ENV{REMOTE_USER};
my $user = $users{$ruser};

if (!$user ) { 
	croak ( qq{user "$ruser" not found in database $filename}); 
	exit;
}

my $dir = getDir($user, $cgi->param('subdir') );

#print "|$dir|";
#print "<preprocess>"; print Dumper $cgi; print Dumper %ENV;


## main branch in the code POST runs on a file; GET for directories	
if ($ENV{'REQUEST_METHOD'} eq 'POST') { 
print "Content-type: text/plain\n\n";
	#if ( ! $cgi->param('confirm') ) {
		#&get_confirm;
	#} else {
		&do_post; 
	#} 
} else { 
print "Content-type: text/html\n\n";
	&do_get; 
} 

		
sub get_confirm {
		#print "Content-type: text/html \n\n<pre>";
		my $filePure = $cgi->param('file');
		my $file = $cgi->param('file');
		$file =~ s,^sgml/,,;
		my $cdlprimePart =  infile2cdlprime("$file");
		my $cdlprime =  infile2cdlprime("$file");
		$cdlprime = "$dataroot/$cdlprime";
		$cdlprime =~ s,/sgml,,;
		my $url = $cgi->url();
		my $urlPost = $url . "?" . $ENV{QUERY_STRING};
		my $message;
		$ENV{QUERY_STRING} =~ m,^subdir=(.*)$,;
		my $dir = $1;
		if ( -e "$cdlprime")  {
			$message = qq{
<p><code>$file</code>, matches an 
existing finding aid<!-- a target="voro-cdlprime"
   href="http://$ENV{SERVER_NAME}/oac-ead$cdlprimePart">[cdlprime]</a>|
<a target="voro-sgml"
   href="http://$ENV{SERVER_NAME}/oac-ead$filePure">[submission]</a -->.
</p>
<ul>
<li>If this finding aid is a <b>replacement for the existing finding aid</b>,
please continue to process this file.
<li>If this is a new finding aid, please rename the file so that it is
unique (and doesn't match the existing finding aid).
</ul>
};
		} else {
			$message =  qq{
<p><code>$file</code>, 
does not match any existing finding
aid.</p>
<ul>
<li>If this is a <b>new finding aid</b>, please continue to process this file.
<li>If this finding aid is a replacement for an existing finding aid,
please rename this file to match the finding aid to be replaced.
<li>Press "OK" to continue to process this file.
</ul>

			};
		}
my $header = getHeader($templatef);
print <<EOF;
$header
<h1><em>voro</em>EAD Production: Confirm</h1>

<div class="doc-body">$message</div>
	
<form action="$urlPost;$filePure" method="POST">
<input type="hidden" name="file" value="$filePure"/>
<input type="submit" name="confirm" value="OK"/>
</form>

<form action="$url" method="GET"/>
<input type="hidden" name="subdir" value="$dir"/>
<input type="submit" value="Cancel"/>
</form>

</div>
<div class="footer"><a href="http://www.oac.cdlib.org/help/help_affiliates.cgi">OAC Con
tributing Members: Questions? Comments?</a><br /><br />
Copyright &copy; <!--#config timefmt="%Y" --><!--#echo var="DATE_LOCAL" --> The Regents of the University of California<br /><br />
</div>
</div>
</body>
</html>
EOF


}
sub do_post {
		my $file = $cgi->param('file');
		$file =~ s,^sgml/,,;


		my $validate_command = "/usr/bin/env perl -I /apps/dsc/branches/production/voro/batch-bin /apps/dsc/branches/production/voro/batch-bin/ark-manifest.pl --onefile $dataroot/$file 2>&1";
		# my $validate_command = "/usr/bin/env /usr/bin/perl -I /apps/dsc/branches/production/voro/batch-bin /apps/dsc/branches/production/voro/batch-bin/ark-manifest.pl --onefile $dataroot/$file";
		# my $validate_command = "/bin/env perl -I /apps/dsc/branches/production/voro/batch-bin /apps/dsc/branches/production/voro/batch-bin/ark-manifest.pl --onefile $dataroot/$file  2>&1";

		$ENV{OACDATA} = $oacdata;
		$ENV{PREFIX} = "/voro/local";
		print `$validate_command`;
                # print "${^CHILD_ERROR_NATIVE}\n";
#print "exit code $exit (# of errors from BPG/status.pl)";


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
			# print Dumper $listing;
			# print "3A";
		} 
		#print "|$dir|";
		if ( $c > 0  && ($dir ne "/")) {
			# print Dumper $search;
			$listing =  filelist($listing, $sgmlfiles, $xmlfiles);
			$isdir = 0;
			# print "3B";
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
		next if ($_ =~ m,/xmlstyle_cache/$,);
		my $ret = $_;
		$ret =~ s,^$dataroot,,;
		push @list, $ret;
	}
	@list = sort @list;
	for (@list) {
		next if ($_ eq '' || $_ eq '/');
		next if ($_ =~ m,xmlstyle_cache,);
		my $testit = $_;
		$testit =~ s,$dir/,,;
		next unless($testit);
		my $item = qq[<a href="$ENV{SCRIPT_NAME}?subdir=$_">$_</a>];
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
		$item = qq{<input name="file" type="radio" value="$item">$item</input>};
		push @return, { 'item'=> $item};
	}
	return \@return;
}


sub getDir {
	my ($user, $askdir) = @_;
	$defaultdir = $user->{dir};
	$askdir =~ s/\.|\;|\<|\>|\?|\n|\f|\r|\\|\|//gi;
	$askdir =~ s,^/*,,g;
	$askdir =~ s,/*$,,g;
	if ($askdir) {
		if ($defaultdir eq "") {
			return "/$askdir";
		} elsif ($askdir =~ m,$defaultdir,) {
			return "/$askdir";
		} else {
			### check in dirs
			#for (@{$user->{dirs}}) {
				#return "/$askdir" if ($_ eq $askdir);
			#}
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

sub infile2cdlprime {
    my ($file) = (@_);
    $file =~ s/.sgm$/.xml/;
    $file =~ m,/([^/]*)/([^/]*).xml,;
        # if $1 eq $2 then its a composite file
        if ( ($1 && $2) && ($1 eq $2) && ( $1 ne 'bancroft' ) ) {
                $file =~ s,$1/,,;
        }
    return $eadroot . "/cdlprime/" . $file;
}


