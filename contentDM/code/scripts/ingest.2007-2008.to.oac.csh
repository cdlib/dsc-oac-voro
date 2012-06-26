#! /usr/bin/tcsh -x

cd /voro/data/oac-lsta/mets/2007-2008
foreach i (`/bin/ls *.mets.xml`)
/voro/code/batch-bin/getMETS.pl http://voro.cdlib.org:8081/workspace/lhdrp.mets/2007-2008/$i
end
