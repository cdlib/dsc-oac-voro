#!/usr/bin/env perl
# create manifest files for Merritt
use Data::Dumper;
use File::Path;
use File::stat;
use Getopt::Std;
use XML::LibXML;
# set up  global $sha2obj to make checksums type SHA-256
# use Digest::SHA;
use Digest;
# my $sha2obj = new Digest::SHA;
my $algorithm;
#my $algorithm = "CRC-32";
my $checksummer = Digest->new($algorithm) if $algorithm;

# lets play nice
# http://stackoverflow.com/questions/8563377/
use BSD::Resource qw(PRIO_PROCESS setpriority);
use Linux::IO_Prio qw(IOPRIO_WHO_PROCESS IOPRIO_PRIO_VALUE IOPRIO_CLASS_BE ioprio_set);
BEGIN { require autodie::hints; autodie::hints->set_hints_for(\&ioprio_set, { fail => sub { $_[0] == -1 } } ) };
use autodie qw(:all setpriority ioprio_set);

setpriority(
    PRIO_PROCESS,       # 1
    $$,
    19
);
ioprio_set(
    IOPRIO_WHO_PROCESS,                         # 1
    $$,
    IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 7)       # 0x4007
);

my $texts_data = $ENV{XTF_DATA} || "$ENV{HOME}/data/xtf/data";
# my $regen = $opt_r;

my $base_url = "http://$ENV{CDN_HOSTNAME}";

my $now = localtime;

# directory trolling
# /data/13030/04/sc1004/
# first loop; should change to an opendir
foreach my $NAAN ("13030", "28722", "20775") {
	# my $NAAN = "13030";
	opendir (SUB, "$texts_data/$NAAN");

	# second loop /04/
	while (my $repdir = readdir(SUB)) {
		# open outer manifest for pair directory
                next if ($repdir eq "." || $repdir eq ".." || $repdir eq "CVS");
		open MANI, ">/dsc/data/in/oac-ead/manifests/$repdir.checkm";
		binmode(MANI, ":utf8");

		print MANI "#%checkm_0.7 \n"; # the space before \n is [sic] from the sample
		print MANI "#%profile | http://uc3.cdlib.org/registry/ingest/manifest/mrt-batch-manifest \n";
		print MANI "#utf8\n";
		print MANI "# url ||||| manifest.checkm | | OAC_ark | creator[1] or contributor[1] | title[1] | date[1]\n";

		opendir (OBJ, "$texts_data/$NAAN/$repdir");

		# third loop /sc1004/
		while (my $objid = readdir(OBJ)) {
                	next if ($objid eq "." || $objid eq ".." || $objid eq "CVS" || $objid eq ".xml");
			# open object manifest
			opendir (STR, "$texts_data/$NAAN/$repdir/$objid/");
			open CHECKM, ">$texts_data/$NAAN/$repdir/$objid/manifest.checkm";
			binmode(CHECKM, ":utf8");

			# print STDOUT "$texts_data/$NAAN/$repdir/$objid/manifest.checkm\n";
			print CHECKM "#%checkm_0.7\n"; 
			print CHECKM "#%profile | http://uc3.cdlib.org/registry/ingest/manifest/mrt-ingest-manifest\n";

			# forth loop all the files in /data/13030/04/sc1004/
			while (my $part = readdir(STR)) {
                		next if ($part eq "." || $part eq ".." || $part eq "CVS" || $part eq "manifest.checkm");
				my $file = "$texts_data/$NAAN/$repdir/$objid/$part";
				# there can be sub-directories
				if ( -d $file ) {
					go_deeper($file, $part);
				} else {
					checkm($file, $part) if (-e $file);
				}
				if ($part eq "$objid.dc.xml") {
					metadata($file, $part, "$texts_data/$NAAN/$repdir/$objid", "ark:/$NAAN/$objid");
				}
			}
			close(CHECKM);
		}
	close(MANI);
	}
}

exit;

sub metadata {
  my ($file, $part, $dir, $local_ark) = @_;
  my $fileURL = file2url("$dir/manifest.checkm");
  # my $size = -s "$dir/manifest.checkm";
  my $dc = XML::LibXML->load_xml( location => $file )->getDocumentElement;
  return unless $dc;
  my $title = $dc->findvalue("normalize-space(/qdc/title[1])");
  my $creator = $dc->findvalue("normalize-space(/qdc/creator[1])");
  my $contributor = $dc->findvalue("normalize-space(/qdc/contributor[1])");
  my $date = $dc->findvalue("normalize-space(/qdc/date[1])");
  $creator = $creator || $contributor;

  # mrt:primaryIdentifier | mrt:localIdentifier | mrt:creator | mrt:title | mrt:date ] 
  # url | [algorithm] | [value] | [size] | | filename [|primary] [|local] [|creator] [|title] [|date] 

  # !! Need some way to escape the values I'm going to put in the file; what are the 
  # the escaping rules?  Do I just =~s,|,,g

  print MANI "$fileURL|||||manifest.checkm||$local_ark|$creator|$title|$date\n"
}

# sub-directories of the main object directory are the 5th loop
sub go_deeper {
  my($file, $part) = @_;
  opendir(INNER, $file);
  while (my $goods = readdir(INNER)){
    next if ($goods eq "." || $goods eq ".." || $goods eq "CVS");
    my $deeper = "$file/$goods";
    checkm($deeper, $goods);
  }
}


# main routine
sub checkm {
   my ($file, $part) =  @_;
   my $fileURL = file2url($file);
   my $size = -s $file;

   # take a checksum ()
   my $checksum;
   if ($checksummer) {
      open (CHK, "<$file");
      binmode(CHK);
      $checksummer->addfile(*CHK);
      $checksum = $checksummer->hexdigest();
      $checksummer->reset();
      close(CHK);
   }

   # Merritt docs do not agree
   # https://merritt.cdlib.org/help/manifest_guide#object_manifest 2012-Aug-04 
   #    fileURL | hashAlgorithm | hashValue | fileSize | filename
   # but that same page links to here:
   # https://merritt.cdlib.org/docs/objectManifestSpecification.txt 2012-Aug-04 
   # and this as well as the checkm spec says there is a spot for the file mofidication time
   # [ #%fields | nfo:fileUrl | nfo:hashAlgorithm | nfo:hashValue | nfo:fileSize | nfo:fileLastModified | nfo:fileName | mrt:mimeType ] 
   # url | [algorithm] | [value] | [size] | | filename [ | mime] 

   # also, spec is unclear on if there should be spaces between values and delimiters
   # spec in unclear on what literal values to use to indicate checksum algorithm
   # does not specify how the checksum should be seralized

   print CHECKM "$fileURL|$algorithm|$checksum|$size||$part\n";

}

sub file2url {
  my ($file) = @_;
  $file =~ s,^/apps/dsc/data/xtf,,;
  return "$base_url$file";
}

