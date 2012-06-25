2008/7/24 4:30pm MAR

Ran script "bad.url.fixing.pl" which read the METS XML in the standard
location ("/voro/data/oac-lsta/mets") and then also read the corresponding
METS XML that had been ingested into voro.  It seeks non-CDL URLs in the
standard location METS XML, and replaces those URLs with the URLs in the
corresponding locations in the voro-ingested METS.

It does that by looking for "/mets:mets/mets:fileSec/mets:fileGrp"s.
Using the "USE" attributes there, it examines the "mets:file" elements
inside it.  When there is only one such, it seeks the same location in the
voro-ingested METS.  When there is more than one "mets:file", it uses
the "GROUPID" attribute to find the same location in the voro-ingested
METS.

It writes updated METS XML files in nearby directory "fixed.mets".

I have verified that there are no non-CDL URLs in the output METS XML files.

In order to make sure that all the URLs in the fixed METS XML files are
valid (i.e., can be fetched successfully), I put together two addition
scripts.  "list.all.href.pl" examines the nearby fixed METS XML files,
and writes all URLs to STDOUT.

./list.all.href.pl > all.href.txt

"check.all.href.pl" attempts to determine if all the mentioned files
exist.  In order to do that for "ingest1" without having to do "wget"s,
I got a directory listing of "/ingest-proxy/LSTA-2ndGen/{caarpl,csb,cwh}".
(The "csmat" subdirectory is not present, and it's not present in my
home directory, which is the destination of the symlinks for the above
three.)  That directory listing is nearby file "files.on.ingest1".
"check.all.href.pl" reads the "ingest1" directory listing.  For
files that should be on this machine, it checks for their existence.

./check.all.href.pl > check.href.txt

The "csmat" URLs show up there, plus a few of the others.  Brian says
that Mark Reyes is rewriting URLs, so they may be fine.  Brian told
me to put the METS in place.  I first backed up the bad ones here:

cd /voro/data/oac-lsta/mets
/usr/bin/tar cf /voro/data/oac-lsta/admin/code/2006-2007.one.shot.fix/bad.mets.tar -I /voro/data/oac-lsta/admin/code/2006-2007.one.shot.fix/mets.list.txt
cd /voro/data/oac-lsta/admin/code/2006-2007.one.shot.fix
gzip bad.mets.tar

Then I moved the rewritten METS file into place:

cd /voro/data/oac-lsta/admin/code/2006-2007.one.shot.fix/fixed.mets
foreach i (c*)
cd $i
/bin/cp * /voro/data/oac-lsta/mets
cd ..
end
