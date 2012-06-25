2009/8/13 4pm MAR

To run the "SCJARexport2_jpg_only.xml" file, which is "Occidental
College Japanese American Relocation Collection images and texts",
INGEST FootPrints ticket number 284, use commands:

% cd /voro/data/oac-lsta/non-lhdrp/contentdm
% ../bin/preprocess.pl SCJARexport2_jpg_only.xml preprocessed_SCJARexport2_jpg_only.xml clo_kt638nc9ww_
% ../bin/run_7train.pl preprocessed_SCJARexport2_jpg_only.xml

% cd /voro/data/oac-lsta/non-lhdrp/mets
% foreach i (`/bin/ls -l | /bin/grep "Aug 13" | /bin/awk '{print $9}' | /bin/grep -v CVS`)
foreach? echo ---------- $i -----------
foreach? /voro/code/batch-bin/getMETS.pl http://voro.cdlib.org:8081/workspace/lsta.but.non.lhdrp.mets/$i
foreach? end

The output of the "getMETS.pl" runs was as follows:

---------- kt0199r4p0.mets.xml -----------
N|image|ark:/13030/kt0199r4p0
---------- kt0290325c.mets.xml -----------
N|image|ark:/13030/kt0290325c
---------- kt087031pz.mets.xml -----------
N|image|ark:/13030/kt087031pz
---------- kt0c60322s.mets.xml -----------
N|image|ark:/13030/kt0c60322s
---------- kt0f59r607.mets.xml -----------
N|image collection|ark:/13030/kt0f59r607
---------- kt0g50324g.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt0g50324g
---------- kt0g503250.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt0g503250
---------- kt0j49r69j.mets.xml -----------
N|image|ark:/13030/kt0j49r69j
---------- kt0j49r6b2.mets.xml -----------
N|image|ark:/13030/kt0j49r6b2
---------- kt0k4033bq.mets.xml -----------
N|image|ark:/13030/kt0k4033bq
---------- kt0p3032vn.mets.xml -----------
N|image collection|ark:/13030/kt0p3032vn
---------- kt0t1nd89s.mets.xml -----------
N|image|ark:/13030/kt0t1nd89s
---------- kt0w1033js.mets.xml -----------
N|image|ark:/13030/kt0w1033js
---------- kt100034rb.mets.xml -----------
N|image collection|ark:/13030/kt100034rb
---------- kt109nd8pj.mets.xml -----------
N|image|ark:/13030/kt109nd8pj
---------- kt129032hv.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt129032hv
---------- kt1489r73m.mets.xml -----------
N|image collection|ark:/13030/kt1489r73m
---------- kt158032xq.mets.xml -----------
N|image|ark:/13030/kt158032xq
---------- kt158032z7.mets.xml -----------
N|image collection|ark:/13030/kt158032z7
---------- kt167nd82j.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt167nd82j
---------- kt187032vb.mets.xml -----------
N|image|ark:/13030/kt187032vb
---------- kt1d5nd96d.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt1d5nd96d
---------- kt1g503678.mets.xml -----------
N|image collection|ark:/13030/kt1g503678
---------- kt1n39r5s8.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt1n39r5s8
---------- kt1s2032qj.mets.xml -----------
N|image|ark:/13030/kt1s2032qj
---------- kt1t1nd92z.mets.xml -----------
N|image collection|ark:/13030/kt1t1nd92z
---------- kt1v19r6n0.mets.xml -----------
N|image|ark:/13030/kt1v19r6n0
---------- kt1x0nd9kc.mets.xml -----------
N|image collection|ark:/13030/kt1x0nd9kc
---------- kt1z09r6t7.mets.xml -----------
N|image|ark:/13030/kt1z09r6t7
---------- kt2000323v.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt2000323v
---------- kt209nd9xz.mets.xml -----------
N|image|ark:/13030/kt209nd9xz
---------- kt229033wb.mets.xml -----------
N|image|ark:/13030/kt229033wb
---------- kt238nf09d.mets.xml -----------
N|image collection|ark:/13030/kt238nf09d
---------- kt267nd9tq.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt267nd9tq
---------- kt267nd9v7.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt267nd9v7
---------- kt2779r4gt.mets.xml -----------
N|image|ark:/13030/kt2779r4gt
---------- kt2b69r6q2.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt2b69r6q2
---------- kt2c60344d.mets.xml -----------
N|image|ark:/13030/kt2c60344d
---------- kt2c60345x.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt2c60345x
---------- kt2d5nd9nf.mets.xml -----------
N|image|ark:/13030/kt2d5nd9nf
---------- kt2d5nd9pz.mets.xml -----------
N|image|ark:/13030/kt2d5nd9pz
---------- kt2g5034d6.mets.xml -----------
N|image collection|ark:/13030/kt2g5034d6
---------- kt2h4nf0wt.mets.xml -----------
N|image|ark:/13030/kt2h4nf0wt
---------- kt2k403457.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt2k403457
---------- kt2k40346r.mets.xml -----------
N|image|ark:/13030/kt2k40346r
---------- kt2m3nf0cq.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt2m3nf0cq
---------- kt2p3032rq.mets.xml -----------
N|image|ark:/13030/kt2p3032rq
---------- kt2r29r7k3.mets.xml -----------
N|image collection|ark:/13030/kt2r29r7k3
---------- kt2s2033wx.mets.xml -----------
N|image collection|ark:/13030/kt2s2033wx
---------- kt2w10339s.mets.xml -----------
N|image|ark:/13030/kt2w10339s
---------- kt309nf24f.mets.xml -----------
N|image|ark:/13030/kt309nf24f
---------- kt309nf25z.mets.xml -----------
N|image|ark:/13030/kt309nf25z
---------- kt309nf26g.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt309nf26g
---------- kt3199r93j.mets.xml -----------
N|image|ark:/13030/kt3199r93j
---------- kt3290339v.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
N|image collection|ark:/13030/kt3290339v
---------- kt358034v8.mets.xml -----------
N|image|ark:/13030/kt358034v8
---------- kt358034ws.mets.xml -----------
N|image|ark:/13030/kt358034ws
---------- kt367nf148.mets.xml -----------
N|image|ark:/13030/kt367nf148
---------- kt367nf15s.mets.xml -----------
N|image|ark:/13030/kt367nf15s
---------- kt3779r9mm.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt3779r9mm
---------- kt3c6033gd.mets.xml -----------
N|image collection|ark:/13030/kt3c6033gd
---------- kt3h4nf1hx.mets.xml -----------
N|image|ark:/13030/kt3h4nf1hx
---------- kt3j49r96c.mets.xml -----------
N|image|ark:/13030/kt3j49r96c
---------- kt3j49r97w.mets.xml -----------
N|image|ark:/13030/kt3j49r97w
---------- kt3k4034j7.mets.xml -----------
N|image|ark:/13030/kt3k4034j7
---------- kt3k4034kr.mets.xml -----------
N|image|ark:/13030/kt3k4034kr
---------- kt3m3nd99w.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt3m3nd99w
---------- kt3m3nd9bd.mets.xml -----------
N|image collection|ark:/13030/kt3m3nd9bd
---------- kt3n39r7wd.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt3n39r7wd
---------- kt3s2034pm.mets.xml -----------
N|image|ark:/13030/kt3s2034pm
---------- kt3s2034q4.mets.xml -----------
N|image|ark:/13030/kt3s2034q4
---------- kt3s2034rn.mets.xml -----------
N|image|ark:/13030/kt3s2034rn
---------- kt3w1035zw.mets.xml -----------
N|image|ark:/13030/kt3w1035zw
---------- kt3z09r7vv.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt3z09r7vv
---------- kt4000344z.mets.xml -----------
N|image|ark:/13030/kt4000344z
---------- kt4199r8r6.mets.xml -----------
N|image|ark:/13030/kt4199r8r6
---------- kt429034d6.mets.xml -----------
N|image|ark:/13030/kt429034d6
---------- kt429034fq.mets.xml -----------
N|image|ark:/13030/kt429034fq
---------- kt438nf2f2.mets.xml -----------
N|image|ark:/13030/kt438nf2f2
---------- kt4489r763.mets.xml -----------
N|image collection|ark:/13030/kt4489r763
---------- kt467nf10h.mets.xml -----------
N|image|ark:/13030/kt467nf10h
---------- kt4779r8mf.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt4779r8mf
---------- kt4779r8nz.mets.xml -----------
N|image collection|ark:/13030/kt4779r8nz
---------- kt496nf11p.mets.xml -----------
N|image|ark:/13030/kt496nf11p
---------- kt4c6036d4.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
N|image collection|ark:/13030/kt4c6036d4
---------- kt4d5nf2rp.mets.xml -----------
N|image collection|ark:/13030/kt4d5nf2rp
---------- kt4d5nf2s6.mets.xml -----------
N|image|ark:/13030/kt4d5nf2s6
---------- kt4d5nf2tq.mets.xml -----------
N|image|ark:/13030/kt4d5nf2tq
---------- kt4d5nf2v7.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt4d5nf2v7
---------- kt4h4nf2hq.mets.xml -----------
N|image|ark:/13030/kt4h4nf2hq
---------- kt4j49r7mx.mets.xml -----------
N|image|ark:/13030/kt4j49r7mx
---------- kt4k40352s.mets.xml -----------
N|image|ark:/13030/kt4k40352s
---------- kt4q2nf0n4.mets.xml -----------
N|image|ark:/13030/kt4q2nf0n4
---------- kt4q2nf0pn.mets.xml -----------
N|image|ark:/13030/kt4q2nf0pn
---------- kt4s2035pd.mets.xml -----------
N|image collection|ark:/13030/kt4s2035pd
---------- kt4s2035qx.mets.xml -----------
N|image|ark:/13030/kt4s2035qx
---------- kt4s2035rf.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt4s2035rf
---------- kt4t1nf1mr.mets.xml -----------
N|image|ark:/13030/kt4t1nf1mr
---------- kt4v19r8tg.mets.xml -----------
N|image|ark:/13030/kt4v19r8tg
---------- kt4v19r8v0.mets.xml -----------
N|image|ark:/13030/kt4v19r8v0
---------- kt4w1035hg.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt4w1035hg
---------- kt4w1035j0.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt4w1035j0
---------- kt4x0nf1rg.mets.xml -----------
N|image|ark:/13030/kt4x0nf1rg
---------- kt500038rh.mets.xml -----------
N|image|ark:/13030/kt500038rh
---------- kt509nf2cp.mets.xml -----------
N|image collection|ark:/13030/kt509nf2cp
---------- kt529035kk.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt529035kk
---------- kt567nf0k4.mets.xml -----------
N|image collection|ark:/13030/kt567nf0k4
---------- kt567nf0mn.mets.xml -----------
N|image collection|ark:/13030/kt567nf0mn
---------- kt587036qf.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt587036qf
---------- kt5b69r9px.mets.xml -----------
N|image|ark:/13030/kt5b69r9px
---------- kt5d5nf17r.mets.xml -----------
N|image|ark:/13030/kt5d5nf17r
---------- kt5f59s0gk.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 738.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 739.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 742.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 743.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 760.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 761.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 777.
Use of uninitialized value in numeric gt (>) at /voro/code/batch-bin/getMETS.pl line 777.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 777.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 779.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 780.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 795.
N|image collection|ark:/13030/kt5f59s0gk
---------- kt5f59s0h3.mets.xml -----------
N|image|ark:/13030/kt5f59s0h3
---------- kt5f59s0jm.mets.xml -----------
N|image collection|ark:/13030/kt5f59s0jm
---------- kt5f59s0k4.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt5f59s0k4
---------- kt5g5035gn.mets.xml -----------
N|image|ark:/13030/kt5g5035gn
---------- kt5h4nf3g0.mets.xml -----------
N|image|ark:/13030/kt5h4nf3g0
---------- kt5h4nf3hh.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt5h4nf3hh
---------- kt5k4035g9.mets.xml -----------
N|image|ark:/13030/kt5k4035g9
---------- kt5m3nf261.mets.xml -----------
N|image|ark:/13030/kt5m3nf261
---------- kt5n39r9bq.mets.xml -----------
N|image|ark:/13030/kt5n39r9bq
---------- kt5r29r8nj.mets.xml -----------
N|image|ark:/13030/kt5r29r8nj
---------- kt5s20363d.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt5s20363d
---------- kt5t1nf2cx.mets.xml -----------
N|image|ark:/13030/kt5t1nf2cx
---------- kt5v19r99h.mets.xml -----------
N|image|ark:/13030/kt5v19r99h
---------- kt600035zg.mets.xml -----------
N|image|ark:/13030/kt600035zg
---------- kt609nf4v6.mets.xml -----------
N|image collection|ark:/13030/kt609nf4v6
---------- kt638nf31z.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt638nf31z
---------- kt6489r98q.mets.xml -----------
N|image|ark:/13030/kt6489r98q
---------- kt6489r997.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt6489r997
---------- kt6489r9br.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt6489r9br
---------- kt6489r9c8.mets.xml -----------
N|image collection|ark:/13030/kt6489r9c8
---------- kt658036x6.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt658036x6
---------- kt696nf28d.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
N|image collection|ark:/13030/kt696nf28d
---------- kt696nf29x.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt696nf29x
---------- kt6b69r9kp.mets.xml -----------
N|image|ark:/13030/kt6b69r9kp
---------- kt6d5nf40w.mets.xml -----------
N|image|ark:/13030/kt6d5nf40w
---------- kt6f59s099.mets.xml -----------
N|image|ark:/13030/kt6f59s099
---------- kt6g5035p2.mets.xml -----------
N|image collection|ark:/13030/kt6g5035p2
---------- kt6h4nf3x1.mets.xml -----------
N|image|ark:/13030/kt6h4nf3x1
---------- kt6h4nf3zj.mets.xml -----------
N|image collection|ark:/13030/kt6h4nf3zj
---------- kt6k4037jm.mets.xml -----------
N|image|ark:/13030/kt6k4037jm
---------- kt6k4037k4.mets.xml -----------
N|image|ark:/13030/kt6k4037k4
---------- kt6k4037mn.mets.xml -----------
N|image|ark:/13030/kt6k4037mn
---------- kt6p3040b7.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
N|image collection|ark:/13030/kt6p3040b7
---------- kt6q2nf43d.mets.xml -----------
N|image|ark:/13030/kt6q2nf43d
---------- kt6s2036wm.mets.xml -----------
N|image collection|ark:/13030/kt6s2036wm
---------- kt6s2036x4.mets.xml -----------
N|image|ark:/13030/kt6s2036x4
---------- kt6t1nf2h9.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt6t1nf2h9
---------- kt6t1nf2jt.mets.xml -----------
N|image|ark:/13030/kt6t1nf2jt
---------- kt6t1nf2kb.mets.xml -----------
N|image|ark:/13030/kt6t1nf2kb
---------- kt6w1038qn.mets.xml -----------
N|image|ark:/13030/kt6w1038qn
---------- kt6w1038r5.mets.xml -----------
N|image|ark:/13030/kt6w1038r5
---------- kt7000371s.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt7000371s
---------- kt70003729.mets.xml -----------
N|image|ark:/13030/kt70003729
---------- kt75803853.mets.xml -----------
N|image|ark:/13030/kt75803853
---------- kt7580386m.mets.xml -----------
N|image|ark:/13030/kt7580386m
---------- kt787035p2.mets.xml -----------
N|image|ark:/13030/kt787035p2
---------- kt787035qk.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt787035qk
---------- kt7b69r8qk.mets.xml -----------
N|image|ark:/13030/kt7b69r8qk
---------- kt7b69r8r3.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt7b69r8r3
---------- kt7c6039jk.mets.xml -----------
N|image|ark:/13030/kt7c6039jk
---------- kt7d5nf45s.mets.xml -----------
N|image|ark:/13030/kt7d5nf45s
---------- kt7f59s1c4.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
N|image|ark:/13030/kt7f59s1c4
---------- kt7g5036f7.mets.xml -----------
N|image|ark:/13030/kt7g5036f7
---------- kt7h4nf3k5.mets.xml -----------
N|image|ark:/13030/kt7h4nf3k5
---------- kt7h4nf3mp.mets.xml -----------
N|image|ark:/13030/kt7h4nf3mp
---------- kt7h4nf3n6.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt7h4nf3n6
---------- kt7k40389s.mets.xml -----------
N|image|ark:/13030/kt7k40389s
---------- kt7m3nf3mb.mets.xml -----------
N|image collection|ark:/13030/kt7m3nf3mb
---------- kt7p3036p5.mets.xml -----------
N|image|ark:/13030/kt7p3036p5
---------- kt7q2nf489.mets.xml -----------
N|image|ark:/13030/kt7q2nf489
---------- kt7q2nf49t.mets.xml -----------
N|image|ark:/13030/kt7q2nf49t
---------- kt7r29r95d.mets.xml -----------
N|image|ark:/13030/kt7r29r95d
---------- kt7s2036rv.mets.xml -----------
N|image|ark:/13030/kt7s2036rv
---------- kt7v19s11k.mets.xml -----------
N|image|ark:/13030/kt7v19s11k
---------- kt7v19s123.mets.xml -----------
N|image|ark:/13030/kt7v19s123
---------- kt7w1038d9.mets.xml -----------
N|image|ark:/13030/kt7w1038d9
---------- kt7w1038ft.mets.xml -----------
N|image|ark:/13030/kt7w1038ft
---------- kt7w1038gb.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt7w1038gb
---------- kt7w1038hv.mets.xml -----------
N|image|ark:/13030/kt7w1038hv
---------- kt8199s28r.mets.xml -----------
N|image|ark:/13030/kt8199s28r
---------- kt8489r95s.mets.xml -----------
N|image|ark:/13030/kt8489r95s
---------- kt867nf4gf.mets.xml -----------
N|image|ark:/13030/kt867nf4gf
---------- kt896nf68z.mets.xml -----------
N|image|ark:/13030/kt896nf68z
---------- kt8c603867.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt8c603867
---------- kt8d5nf2rx.mets.xml -----------
N|image|ark:/13030/kt8d5nf2rx
---------- kt8h4nf4dc.mets.xml -----------
N|image collection|ark:/13030/kt8h4nf4dc
---------- kt8h4nf4fw.mets.xml -----------
N|image|ark:/13030/kt8h4nf4fw
---------- kt8k4037cn.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt8k4037cn
---------- kt8k4037d5.mets.xml -----------
N|image collection|ark:/13030/kt8k4037d5
---------- kt8m3nf6xr.mets.xml -----------
N|image|ark:/13030/kt8m3nf6xr
---------- kt8p30376q.mets.xml -----------
N|image|ark:/13030/kt8p30376q
---------- kt8p303777.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt8p303777
---------- kt8s20380r.mets.xml -----------
N|image|ark:/13030/kt8s20380r
---------- kt8t1nf535.mets.xml -----------
N|image|ark:/13030/kt8t1nf535
---------- kt8w10375h.mets.xml -----------
N|image|ark:/13030/kt8w10375h
---------- kt8w103761.mets.xml -----------
N|image|ark:/13030/kt8w103761
---------- kt8x0nf5q4.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt8x0nf5q4
---------- kt8x0nf5rn.mets.xml -----------
N|image|ark:/13030/kt8x0nf5rn
---------- kt8z09s0nc.mets.xml -----------
N|image|ark:/13030/kt8z09s0nc
---------- kt8z09s0pw.mets.xml -----------
N|image collection|ark:/13030/kt8z09s0pw
---------- kt8z09s0qd.mets.xml -----------
N|image collection|ark:/13030/kt8z09s0qd
---------- kt9199s2st.mets.xml -----------
N|image collection|ark:/13030/kt9199s2st
---------- kt929038pt.mets.xml -----------
N|image|ark:/13030/kt929038pt
---------- kt929038qb.mets.xml -----------
N|image collection|ark:/13030/kt929038qb
---------- kt938nf66x.mets.xml -----------
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt938nf66x
---------- kt938nf67f.mets.xml -----------
N|image collection|ark:/13030/kt938nf67f
---------- kt958037w3.mets.xml -----------
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in subroutine entry at /voro/code/batch-bin/getMETS.pl line 458.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 740.
Use of uninitialized value in -e at /voro/code/batch-bin/getMETS.pl line 744.
Use of uninitialized value in numeric le (<=) at /voro/code/batch-bin/getMETS.pl line 762.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 778.
Use of uninitialized value in addition (+) at /voro/code/batch-bin/getMETS.pl line 781.
N|image collection|ark:/13030/kt958037w3
---------- kt958037xm.mets.xml -----------
N|image|ark:/13030/kt958037xm
---------- kt9d5nf3rq.mets.xml -----------
N|image collection|ark:/13030/kt9d5nf3rq
---------- kt9f59s1x1.mets.xml -----------
N|image collection|ark:/13030/kt9f59s1x1
---------- kt9f59s1zj.mets.xml -----------
N|image|ark:/13030/kt9f59s1zj
---------- kt9h4nf4n9.mets.xml -----------
N|image collection|ark:/13030/kt9h4nf4n9
---------- kt9k4039jh.mets.xml -----------
N|image|ark:/13030/kt9k4039jh
---------- kt9m3nf514.mets.xml -----------
N|image|ark:/13030/kt9m3nf514
---------- kt9m3nf52n.mets.xml -----------
N|image collection|ark:/13030/kt9m3nf52n
---------- kt9n39s0d3.mets.xml -----------
N|image collection|ark:/13030/kt9n39s0d3
---------- kt9n39s0fm.mets.xml -----------
N|image collection|ark:/13030/kt9n39s0fm
---------- kt9p3038c3.mets.xml -----------
N|image|ark:/13030/kt9p3038c3
---------- kt9p3038dm.mets.xml -----------
N|image|ark:/13030/kt9p3038dm
---------- kt9r29s2vf.mets.xml -----------
N|image|ark:/13030/kt9r29s2vf
---------- kt9s204104.mets.xml -----------
N|image collection|ark:/13030/kt9s204104
---------- kt9v19s0n1.mets.xml -----------
N|image|ark:/13030/kt9v19s0n1

Also, added the new METS files to CVS:

% cd /voro/data/oac-lsta/non-lhdrp/mets
% foreach i (`/bin/ls -l | /bin/grep "Aug 13" | /bin/awk '{print $9}' | /bin/grep -v CVS`)
foreach? cvs add $i
foreach? cvs commit -m "Initial file." $i
foreach? end

(Its output was unremarkable, and, so, is not included here.)
