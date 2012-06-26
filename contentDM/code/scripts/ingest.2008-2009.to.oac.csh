#! /usr/bin/tcsh -x

cd /voro/data/oac-lsta/mets/2008-2009
foreach i (`/bin/ls *.mets.xml`)
/voro/code/batch-bin/getMETS.pl http://voro.cdlib.org:8081/workspace/lhdrp.mets/2008-2009/$i
end
