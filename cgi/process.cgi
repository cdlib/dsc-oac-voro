#!/usr/bin/env perl
#

use File::List;
use File::Path;
use CGI;
use CGI::Carp qw(fatalsToBrowser) ;
use HTML::Entities ();
use HTML::Template;
use BerkeleyDB ;
use Fcntl;
use MLDBM qw(DB_File Storable) ;
use Data::Dumper;
#use Date::Parse;
use Date::Format qw(ctime time2str);
use Date::Manip;
use strict;

my $filename = "/apps/dsc/users/apache/test.user.bdb";
my $dataroot = "/apps/dsc/data/in/oac-ead/submission";
my $prime2002 = "/apps/dsc/data/in/oac-ead/prime2002";
# my $sendmail = "/usr/lib/sendmail -i -t";
my $sendmail = "/usr/sbin/sendmail -i -t";
my $templatef = "process.tmpl";
my $status = 0;

# let's play nice
setpriority( "PRIO_PROCESS", 0 , "19") || die ("$0: $! not nice\n");


my %users;
my $db = tie (%users, "MLDBM", "$filename", O_RDONLY, 0644 )|| die ("$!, $_");

my $cgi = new CGI;

my $ok_chars = 'a-zA-Z0-9-_\/\.';

foreach my $param_name ( $cgi->param() ) {
     $_ = HTML::Entities::decode( $cgi->param($param_name) );
     $_ =~ s/[^$ok_chars]//go;  
     $cgi->param($param_name,$_);
}               


my $ruser = $ENV{REMOTE_USER};
#my $ruser= 'tingle';
#my $ruser= 'mar';
my $user = $users{$ruser};

if (!$user ) { 
	croak ( qq{user "$ruser" not found in database $filename}); 
	exit;
}

print "Content-type: text/html\n\n";
my $dir = getDir($user, $cgi->param('subdir') );

#print "|$dir|";
#print "<preprocess>"; print Dumper $cgi; print Dumper %ENV;
#print Dumper $user;


## main branch in the code POST runs on a file; GET for directories	
if ($ENV{'REQUEST_METHOD'} eq 'POST') { 
	if ( ! $cgi->param('confirm') ) {
		&get_confirm;
	} else {
		&do_post; 
	} 
} else { 
	&do_get; 
} 

		
sub get_confirm {
		#print "Content-type: text/html \n\n<pre>";
		my $filePure = $cgi->param('file');
		my $file = $cgi->param('file');
		$file =~ s,^submission/,,;
		my $cdlprimePart =  infile2cdlprime("$file");
		my $cdlprime =  infile2cdlprime("$file");
		$cdlprime = "$dataroot/$cdlprime";
		$cdlprime =~ s,/submission,,;
		#my $url = $cgi->url();
                my $url = "/cgi/process.cgi";
		my $urlPost = $url . "?" . $ENV{QUERY_STRING};
		my $message;
		$ENV{QUERY_STRING} =~ m,^subdir=(.*)$,;
		my $dir = $1;
		if ( -e "$cdlprime")  {
			$message = qq{
<p><code>$file</code>, matches an 
existing finding aid<!-- a target="voro-cdlprime"
   href="http://$ENV{VORO_HOSTNAME}/oac-ead$cdlprimePart">[cdlprime]</a>|
<a target="voro-submission"
   href="http://$ENV{VORO_HOSTNAME}/oac-ead$filePure">[submission]</a -->.
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
<p><code>$file</code>, $cdlprime
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
<div class="footer">
<hr>
<b>Questions? Contact us at: </b>
<a href="mailto:oacops\@cdlib.org">oacops\@cdlib.org</a>
</div>
</div>
</body>
</html>
EOF


}
sub do_post {
   defined (my $kid = fork) or die ("could not fork");
	my $file = $cgi->param('file');
	$file =~ s,^submission/,,;
	my $time = time;
	my $date_string = ctime($time);
	my $day_dir = time2str ("%Y%m%d",$time);
        my $time_dir = time2str ("%H%M%S",$time);
        my $year_dir = time2str ("%Y",$time);
	my $next_batch = UnixDate("next Saturday","Saturday %b %e, %Y");
#	my $next_online = UnixDate("next Tuesday","Tuesday %b %e, %Y");
	my $sroot = $dataroot;
	$sroot =~ s,\/submission,,;
	my $part = "$file.$time_dir.html";
	my $results_file = "$sroot/reports/$year_dir/$day_dir/$part";
	my $mk_dir = $results_file;
	$mk_dir =~ s,/([^/]*)$,/,;
	my $results_url = "http://$ENV{SERVER_NAME}/oac-ead/reports";
	$results_url .= "/$year_dir/$day_dir/$part";
	my $header = getHeader($templatef);
   if ($kid) {
	#parent block

	print qq{
$header
<h2>File processing in progress</h2>
<p>You will get an email at $user->{email} shortly, with a link to 
a report indicating processing results.
</p>

<!-- p>The URL  
<a href="$results_url">$results_url</a> will have the results.
</p -->};

   } else {

	#child block
	close(STDIN); close(STDOUT); close(STDERR);
	mkpath ($mk_dir);	
	open(MESSAGE, ">$results_file") or die "can't open log";
print MESSAGE <<EOF;
$header
<h1><em>voro</em>EAD Production: Processing Results</h1>
EOF

print MESSAGE "<p>$date_string</p>";

print MESSAGE <<EOF;
<p>Validating file for compliance with the EAD DTD and <em>OAC Best Practice Guidelines 
  for EAD</em>. Please be patient with large files. To keep a log of validation 
  messages, or as a receipt, save or print a copy of this web page. </p>
<p>Please report problems with <em>voro</em>EAD by sending us an email at: <a href="mailto:oacops\@cdlib.org">oacops\@cdlib.org</a>. 
Include the URL for this processing results page in your message.</p>

<pre><font size=2>
EOF

		my $validate_command = "eadator $dataroot/$file 2>&1";
		my $process_command = "perl /apps/dsc/branches/production/voro/batch-bin/chewEad.pl $file nada $user->{email} 2>&1";
		my $process_command_pass = "perl /apps/dsc/branches/production/voro/batch-bin/chewEad.pl $file null $user->{email} 2>&1";

		my $add_c_order_attributes_command =
			"/apps/dsc/branches/production/voro/batch-bin/add.c-order.attributes.pl " .
			"$prime2002/$file 2>&1";

		$ENV{PREFIX} = "/apps/dsc/local";
		#print "$validate_command\n<br>";
		print MESSAGE `$validate_command`;
		print MESSAGE "\n</pre><br>";

		my $exit = $? >> 8;
		$status = $exit;
		print MESSAGE "</font>";
		if ($exit eq "3" or $exit eq "4") {
		  print MESSAGE "<h2>EAD2002 DTD Validation Errors</h2>";
		  print MESSAGE qq{<p>Email this report's URL to oacops\@cdlib.org if you can't
			decipher the error message above</p>};
		}
		open(SENDMAIL, "|$sendmail") or die "can't run $sendmail";
		print SENDMAIL "Reply-to: oacops\@cdlib.org\n";
		print SENDMAIL "From: OAC Operations Team <oacops\@cdlib.org>\n";
		print SENDMAIL "To: $user->{email}\n";

		if ($status == 0) {

			print MESSAGE "<pre>";

			print MESSAGE `$process_command_pass`;
			$exit = $? >> 8;
	
			print MESSAGE "</pre>";
			$status = $exit;
			$file =~ s,\.sgm$,\.xml,;
			
			if ($status == 0) {
				# We want to run the "prime2002" version of
				# the finding aid, which was apparently
				# processed successfully by chewEad.pl,
				# through the script that adds the "score",
				# "C-ORDER", and "MAX-C-ORDER" attributes.  If
				# this script fails, it's not a deal-breaker,
				# because the finding aid will have those
				# things added by XSLT (but that will be slow).
				# Thus, if something goes wrong, just make a
				# note, and don't bring things to a halt.  (So
				# we don't check the exit code here.)
				print MESSAGE "<pre>\n";
				print MESSAGE "running ",
					"\"$add_c_order_attributes_command\"\n";
				print MESSAGE `$add_c_order_attributes_command`;
				print MESSAGE "</pre>\n";

				print SENDMAIL "Subject: voroEAD: File Processed\n";
				print SENDMAIL "Content-type: text/plain\n\n";
#				print SENDMAIL "File $file queued for publication.\n";
#"\nAt noon on $next_batch the phase of processing will start,
#$file should be on-line by $next_online.\n";

				print SENDMAIL "File $file queued for publication.\n";
				print SENDMAIL

"\nThis finding aid should be online tomorrow. If your finding aid does not appear then, please send us an email at the email address listed below.\n";

#				print MESSAGE qq{<h2>File queued for publication</h2>
#<p>This file should be online by $next_online.  To remove files from the publication queue once accepted by voroEAD,
#please send a request via <a href="http://www.oac.cdlib.org/help/help_affiliates.cgi">OAC Contributing Members Support</a> form; include the file name in
#your request.</p>};
				print MESSAGE qq{<h2>File queued for publication</h2>
<p>This file should be online tomorrow.  To remove files from the publication queue once accepted by voroEAD,
please send us an email at: <a href="mailto:oacops\@cdlib.org">oacops\@cdlib.org</a>.</p>};

			} else {
				print SENDMAIL "Subject: voroEAD: Failed Processing\n";
				print SENDMAIL "Content-type: text/plain\n\n";
				print MESSAGE "<h2>File Failed Processing</h2>";
			}
			print SENDMAIL "\nSee $results_url for a detailed processing results report\n";
		
			print SENDMAIL "\nThank you,\n\nOAC Operations Group\n";	
			print SENDMAIL "oacops\@cdlib.org\n";
			print MESSAGE qq{
<div class="footer">
<hr>
<b>Questions? Contact us at: </b><a href="mailto:oacops\@cdlib.org">oacops\@cdlib.org</a></div>
</body></html>};
			close(MESSAGE);
			close(SENDMAIL);

		} else {  # BPG failed
print MESSAGE <<EOF;
<h2>File rejected by <em>voro</em>EAD due to errors</h2>

<p>Please correct the errors and reprocess the file.
EOF
#print "exit code	 $exit (# of errors from BPG/status.pl)";
 print SENDMAIL "Subject: voroEAD: Failed BPG checking\n";
 print SENDMAIL "Content-type: text/plain\n\n";
			print SENDMAIL "\nSee $results_url for a detailed processing results report\n";
		
			print SENDMAIL "\nThank you,\n\nOAC Operations Group\n";	
			print SENDMAIL "oacops\@cdlib.org\n";
 print MESSAGE "<h2>File Failed Processing</h2>";
		} 

print MESSAGE <<EOF;
</div>
<div class="footer"><hr><b>Questions? Contact us at: </b><a href="mailto:oacops\@cdlib.org">oacops\@cdlib.org</a>
</div>
</div>
</body>
</html>
EOF

	close(MESSAGE);
	close(SENDMAIL);

	} # ends fork's block
}

sub do_get {
		my $template = HTML::Template->new(filename => $templatef);

		my $isdir;

		my @listing;
		my $listing;	
		#print "1: $dir <br>";
		my $checkdir;
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
			#print Dumper $listing;
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
	#print "dirlist:";
	#print Dumper @_;
	my @return;
	my @list;
	my ($dirs) = @_;
	for (@{$dirs}) {
		next if ($_ =~ m,/CVS/$,);
		next if ($_ =~ m,/.hg/$,);
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
	#print "filelist:";
	#print Dumper @_;
	$listing = [] unless ($listing);
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
	#print Dumper @list;
	for (@list) {
		my $item = $_;
		$item =~ s,//,/,g;
		$item = qq{<input name="file" type="radio" value="submission$item">submission$item</input>};
		push @return, { 'item'=> $item};
	}
	return \@return;
}


sub getDir {
	my ($user, $askdir) = @_;
	my $defaultdir = $user->{dir};
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
	while (my $line = <IN>) {
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
    return "/prime2002/" . $file;
}


