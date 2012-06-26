2009/8/13 5:15pm MAR

To run the "ccber.xml" file, which is "UCSB Cheadle Center for Biodiversity &
Ecological Restoration - Katherine Esau collection", INGEST FoorPrints ticket
number 218, add an "<institution>" entry for the institution, using the
information that Adrian provided in the ticket, on the e-mail message
dated today at 2:23pm.  This is in file
"/voro/data/oac-lsta/non-lhdrp/7train/institutions.xml".  (Commit this file
to CVS.)

Then, use commands:

% cd /voro/data/oac-lsta/non-lhdrp/contentdm
% ../bin/preprocess.pl ccber.xml preprocessed_ccber.xml ccber_kt1s20304s_
% mkdir ../mets.ccber
% ../bin/run_7train.pl preprocessed_ccber.xml "" "" "" ../mets.ccber
% cd ../mets.ccber
% cp *.xml ../mets

Then, to ingest, use commands:

% cd /voro/data/oac-lsta/non-lhdrp/mets.ccber
% foreach i (`/bin/ls`)
foreach? echo ---------- $i -----------
foreach? /voro/code/batch-bin/getMETS.pl http://voro.cdlib.org:8081/workspace/lsta.but.non.lhdrp.mets/$i
foreach? end

The output of the "getMETS.pl" runs was as follows:

---------- kt009nd7xc.mets.xml -----------
N|image|ark:/13030/kt009nd7xc
---------- kt0199r4qh.mets.xml -----------
N|image|ark:/13030/kt0199r4qh
---------- kt0199r4r1.mets.xml -----------
N|image|ark:/13030/kt0199r4r1
---------- kt0199r4sj.mets.xml -----------
N|image|ark:/13030/kt0199r4sj
---------- kt0199r4t2.mets.xml -----------
N|image|ark:/13030/kt0199r4t2
---------- kt0199r4vk.mets.xml -----------
N|image|ark:/13030/kt0199r4vk
---------- kt0290326w.mets.xml -----------
N|image|ark:/13030/kt0290326w
---------- kt0290327d.mets.xml -----------
N|image|ark:/13030/kt0290327d
---------- kt0489r519.mets.xml -----------
N|image|ark:/13030/kt0489r519
---------- kt058031qt.mets.xml -----------
N|image|ark:/13030/kt058031qt
---------- kt058031rb.mets.xml -----------
N|image|ark:/13030/kt058031rb
---------- kt058031sv.mets.xml -----------
N|image|ark:/13030/kt058031sv
---------- kt058031tc.mets.xml -----------
N|image|ark:/13030/kt058031tc
---------- kt096nd8p6.mets.xml -----------
N|image|ark:/13030/kt096nd8p6
---------- kt0b69r676.mets.xml -----------
N|image|ark:/13030/kt0b69r676
---------- kt0b69r68q.mets.xml -----------
N|image|ark:/13030/kt0b69r68q
---------- kt0b69r697.mets.xml -----------
N|image|ark:/13030/kt0b69r697
---------- kt0b69r6br.mets.xml -----------
N|image|ark:/13030/kt0b69r6br
---------- kt0c603239.mets.xml -----------
N|image|ark:/13030/kt0c603239
---------- kt0c60324t.mets.xml -----------
N|image|ark:/13030/kt0c60324t
---------- kt0d5nf0th.mets.xml -----------
N|image|ark:/13030/kt0d5nf0th
---------- kt0d5nf0v1.mets.xml -----------
N|image|ark:/13030/kt0d5nf0v1
---------- kt0f59r61r.mets.xml -----------
N|image|ark:/13030/kt0f59r61r
---------- kt0g50326h.mets.xml -----------
N|image|ark:/13030/kt0g50326h
---------- kt0j49r6ck.mets.xml -----------
N|image|ark:/13030/kt0j49r6ck
---------- kt0j49r6d3.mets.xml -----------
N|image|ark:/13030/kt0j49r6d3
---------- kt0k4033c7.mets.xml -----------
N|image|ark:/13030/kt0k4033c7
---------- kt0m3nd790.mets.xml -----------
N|image|ark:/13030/kt0m3nd790
---------- kt0m3nd7bh.mets.xml -----------
N|image|ark:/13030/kt0m3nd7bh
---------- kt0m3nd7c1.mets.xml -----------
N|image|ark:/13030/kt0m3nd7c1
---------- kt0n39r5x1.mets.xml -----------
N|image|ark:/13030/kt0n39r5x1
---------- kt0p3032w5.mets.xml -----------
N|image|ark:/13030/kt0p3032w5
---------- kt0q2nd99m.mets.xml -----------
N|image|ark:/13030/kt0q2nd99m
---------- kt0q2nd9b4.mets.xml -----------
N|image|ark:/13030/kt0q2nd9b4
---------- kt0q2nd9cn.mets.xml -----------
N|image|ark:/13030/kt0q2nd9cn
---------- kt0s2030jp.mets.xml -----------
N|image|ark:/13030/kt0s2030jp
---------- kt0s2030k6.mets.xml -----------
N|image|ark:/13030/kt0s2030k6
---------- kt0t1nd8b9.mets.xml -----------
N|image|ark:/13030/kt0t1nd8b9
---------- kt0v19r5s8.mets.xml -----------
N|image|ark:/13030/kt0v19r5s8
---------- kt0v19r5ts.mets.xml -----------
N|image|ark:/13030/kt0v19r5ts
---------- kt0w1033k9.mets.xml -----------
N|image|ark:/13030/kt0w1033k9
---------- kt0x0nf0k5.mets.xml -----------
N|image|ark:/13030/kt0x0nf0k5
---------- kt0z09r3sz.mets.xml -----------
N|image|ark:/13030/kt0z09r3sz
---------- kt100034sv.mets.xml -----------
N|image|ark:/13030/kt100034sv
---------- kt1199r5bm.mets.xml -----------
N|image|ark:/13030/kt1199r5bm
---------- kt129032jc.mets.xml -----------
N|image|ark:/13030/kt129032jc
---------- kt138nf1d4.mets.xml -----------
N|image|ark:/13030/kt138nf1d4
---------- kt1489r744.mets.xml -----------
N|image|ark:/13030/kt1489r744
---------- kt1489r75n.mets.xml -----------
N|image|ark:/13030/kt1489r75n
---------- kt15803307.mets.xml -----------
N|image|ark:/13030/kt15803307
---------- kt187032wv.mets.xml -----------
N|image|ark:/13030/kt187032wv
---------- kt196nd7nh.mets.xml -----------
N|image|ark:/13030/kt196nd7nh
---------- kt1b69r6ss.mets.xml -----------
N|image|ark:/13030/kt1b69r6ss
---------- kt1c6033f8.mets.xml -----------
N|image|ark:/13030/kt1c6033f8
---------- kt1c6033gs.mets.xml -----------
N|image|ark:/13030/kt1c6033gs
---------- kt1d5nd97x.mets.xml -----------
N|image|ark:/13030/kt1d5nd97x
---------- kt1g50368s.mets.xml -----------
N|image|ark:/13030/kt1g50368s
---------- kt1k4033d2.mets.xml -----------
N|image|ark:/13030/kt1k4033d2
---------- kt1k4033fk.mets.xml -----------
N|image|ark:/13030/kt1k4033fk
---------- kt1k4033g3.mets.xml -----------
N|image|ark:/13030/kt1k4033g3
---------- kt1p3035h7.mets.xml -----------
N|image|ark:/13030/kt1p3035h7
---------- kt1q2nd8w7.mets.xml -----------
N|image|ark:/13030/kt1q2nd8w7
---------- kt1s2032r2.mets.xml -----------
N|image|ark:/13030/kt1s2032r2
---------- kt1t1nd93g.mets.xml -----------
N|image|ark:/13030/kt1t1nd93g
---------- kt1v19r6ph.mets.xml -----------
N|image|ark:/13030/kt1v19r6ph
---------- kt1v19r6q1.mets.xml -----------
N|image|ark:/13030/kt1v19r6q1
---------- kt1v19r6rj.mets.xml -----------
N|image|ark:/13030/kt1v19r6rj
---------- kt2000324c.mets.xml -----------
N|image|ark:/13030/kt2000324c
---------- kt209nd9zg.mets.xml -----------
N|image|ark:/13030/kt209nd9zg
---------- kt209nf003.mets.xml -----------
N|image|ark:/13030/kt209nf003
---------- kt229033xv.mets.xml -----------
N|image|ark:/13030/kt229033xv
---------- kt229033zc.mets.xml -----------
N|image|ark:/13030/kt229033zc
---------- kt238nf0bx.mets.xml -----------
N|image|ark:/13030/kt238nf0bx
---------- kt238nf0cf.mets.xml -----------
N|image|ark:/13030/kt238nf0cf
---------- kt238nf0dz.mets.xml -----------
N|image|ark:/13030/kt238nf0dz
---------- kt258033sf.mets.xml -----------
N|image|ark:/13030/kt258033sf
---------- kt267nd9wr.mets.xml -----------
N|image|ark:/13030/kt267nd9wr
---------- kt2779r4hb.mets.xml -----------
N|image|ark:/13030/kt2779r4hb
---------- kt2779r4jv.mets.xml -----------
N|image|ark:/13030/kt2779r4jv
---------- kt296nd9g6.mets.xml -----------
N|image|ark:/13030/kt296nd9g6
---------- kt2b69r6rk.mets.xml -----------
N|image|ark:/13030/kt2b69r6rk
---------- kt2b69r6s3.mets.xml -----------
N|image|ark:/13030/kt2b69r6s3
---------- kt2b69r6tm.mets.xml -----------
N|image|ark:/13030/kt2b69r6tm
---------- kt2c60346f.mets.xml -----------
N|image|ark:/13030/kt2c60346f
---------- kt2c60347z.mets.xml -----------
N|image|ark:/13030/kt2c60347z
---------- kt2d5nd9qg.mets.xml -----------
N|image|ark:/13030/kt2d5nd9qg
---------- kt2g5034fq.mets.xml -----------
N|image|ark:/13030/kt2g5034fq
---------- kt2j49r6gr.mets.xml -----------
N|image|ark:/13030/kt2j49r6gr
---------- kt2j49r6h8.mets.xml -----------
N|image|ark:/13030/kt2j49r6h8
---------- kt2j49r6js.mets.xml -----------
N|image|ark:/13030/kt2j49r6js
---------- kt2j49r6k9.mets.xml -----------
N|image|ark:/13030/kt2j49r6k9
---------- kt2k403478.mets.xml -----------
N|image|ark:/13030/kt2k403478
---------- kt2p3032s7.mets.xml -----------
N|image|ark:/13030/kt2p3032s7
---------- kt2p3032tr.mets.xml -----------
N|image|ark:/13030/kt2p3032tr
---------- kt2p3032v8.mets.xml -----------
N|image|ark:/13030/kt2p3032v8
---------- kt2q2nf0vm.mets.xml -----------
N|image|ark:/13030/kt2q2nf0vm
---------- kt2s2033xf.mets.xml -----------
N|image|ark:/13030/kt2s2033xf
---------- kt2t1nf2c0.mets.xml -----------
N|image|ark:/13030/kt2t1nf2c0
---------- kt2t1nf2dh.mets.xml -----------
N|image|ark:/13030/kt2t1nf2dh
---------- kt2t1nf2f1.mets.xml -----------
N|image|ark:/13030/kt2t1nf2f1
---------- kt2t1nf2gj.mets.xml -----------
N|image|ark:/13030/kt2t1nf2gj
---------- kt2w1033b9.mets.xml -----------
N|image|ark:/13030/kt2w1033b9
---------- kt2w1033ct.mets.xml -----------
N|image|ark:/13030/kt2w1033ct
---------- kt2w1033db.mets.xml -----------
N|image|ark:/13030/kt2w1033db
---------- kt2z09r6jd.mets.xml -----------
N|image|ark:/13030/kt2z09r6jd
---------- kt309nf270.mets.xml -----------
N|image|ark:/13030/kt309nf270
---------- kt309nf28h.mets.xml -----------
N|image|ark:/13030/kt309nf28h
---------- kt309nf291.mets.xml -----------
N|image|ark:/13030/kt309nf291
---------- kt3199r942.mets.xml -----------
N|image|ark:/13030/kt3199r942
---------- kt3199r95k.mets.xml -----------
N|image|ark:/13030/kt3199r95k
---------- kt329033bc.mets.xml -----------
N|image|ark:/13030/kt329033bc
---------- kt367nf169.mets.xml -----------
N|image|ark:/13030/kt367nf169
---------- kt367nf17t.mets.xml -----------
N|image|ark:/13030/kt367nf17t
---------- kt367nf18b.mets.xml -----------
N|image|ark:/13030/kt367nf18b
---------- kt3779r9n4.mets.xml -----------
N|image|ark:/13030/kt3779r9n4
---------- kt396nf1w9.mets.xml -----------
N|image|ark:/13030/kt396nf1w9
---------- kt3b69r7j8.mets.xml -----------
N|image|ark:/13030/kt3b69r7j8
---------- kt3b69r7ks.mets.xml -----------
N|image|ark:/13030/kt3b69r7ks
---------- kt3d5nf0zh.mets.xml -----------
N|image|ark:/13030/kt3d5nf0zh
---------- kt3d5nf10h.mets.xml -----------
N|image|ark:/13030/kt3d5nf10h
---------- kt3f59r7t2.mets.xml -----------
N|image|ark:/13030/kt3f59r7t2
---------- kt3f59r7vk.mets.xml -----------
N|image|ark:/13030/kt3f59r7vk
---------- kt3g503519.mets.xml -----------
N|image|ark:/13030/kt3g503519
---------- kt3g50352t.mets.xml -----------
N|image|ark:/13030/kt3g50352t
---------- kt3g50353b.mets.xml -----------
N|image|ark:/13030/kt3g50353b
---------- kt3k4034m8.mets.xml -----------
N|image|ark:/13030/kt3k4034m8
---------- kt3k4034ns.mets.xml -----------
N|image|ark:/13030/kt3k4034ns
---------- kt3m3nd9cx.mets.xml -----------
N|image|ark:/13030/kt3m3nd9cx
---------- kt3m3nd9df.mets.xml -----------
N|image|ark:/13030/kt3m3nd9df
---------- kt3n39r7xx.mets.xml -----------
N|image|ark:/13030/kt3n39r7xx
---------- kt3n39r7zf.mets.xml -----------
N|image|ark:/13030/kt3n39r7zf
---------- kt3n39r80f.mets.xml -----------
N|image|ark:/13030/kt3n39r80f
---------- kt3p303613.mets.xml -----------
N|image|ark:/13030/kt3p303613
---------- kt3r29r6x3.mets.xml -----------
N|image|ark:/13030/kt3r29r6x3
---------- kt3r29r6zm.mets.xml -----------
N|image|ark:/13030/kt3r29r6zm
---------- kt3s2034s5.mets.xml -----------
N|image|ark:/13030/kt3s2034s5
---------- kt3s2034tp.mets.xml -----------
N|image|ark:/13030/kt3s2034tp
---------- kt3t1nf15q.mets.xml -----------
N|image|ark:/13030/kt3t1nf15q
---------- kt3t1nf167.mets.xml -----------
N|image|ark:/13030/kt3t1nf167
---------- kt3v19r97v.mets.xml -----------
N|image|ark:/13030/kt3v19r97v
---------- kt3v19r98c.mets.xml -----------
N|image collection|ark:/13030/kt3v19r98c
---------- kt3w10360w.mets.xml -----------
N|image|ark:/13030/kt3w10360w
---------- kt4000345g.mets.xml -----------
N|image|ark:/13030/kt4000345g
---------- kt409nf1k0.mets.xml -----------
N|image|ark:/13030/kt409nf1k0
---------- kt409nf1mh.mets.xml -----------
N|image|ark:/13030/kt409nf1mh
---------- kt4199r8sq.mets.xml -----------
N|image|ark:/13030/kt4199r8sq
---------- kt429034g7.mets.xml -----------
N|image|ark:/13030/kt429034g7
---------- kt429034hr.mets.xml -----------
N|image|ark:/13030/kt429034hr
---------- kt4489r77m.mets.xml -----------
N|image|ark:/13030/kt4489r77m
---------- kt458034fc.mets.xml -----------
N|image|ark:/13030/kt458034fc
---------- kt458034gw.mets.xml -----------
N|image|ark:/13030/kt458034gw
---------- kt458034hd.mets.xml -----------
N|image|ark:/13030/kt458034hd
---------- kt467nf111.mets.xml -----------
N|image|ark:/13030/kt467nf111
---------- kt467nf12j.mets.xml -----------
N|image|ark:/13030/kt467nf12j
---------- kt4779r8pg.mets.xml -----------
N|image|ark:/13030/kt4779r8pg
---------- kt4779r8q0.mets.xml -----------
N|image|ark:/13030/kt4779r8q0
---------- kt487035j2.mets.xml -----------
N|image|ark:/13030/kt487035j2
---------- kt487035kk.mets.xml -----------
N|image|ark:/13030/kt487035kk
---------- kt487035m3.mets.xml -----------
N|image|ark:/13030/kt487035m3
---------- kt487035nm.mets.xml -----------
N|image|ark:/13030/kt487035nm
---------- kt496nf126.mets.xml -----------
N|image|ark:/13030/kt496nf126
---------- kt4b69r87d.mets.xml -----------
N|image|ark:/13030/kt4b69r87d
---------- kt4c6036fn.mets.xml -----------
N|image|ark:/13030/kt4c6036fn
---------- kt4c6036g5.mets.xml -----------
N|image|ark:/13030/kt4c6036g5
---------- kt4d5nf2wr.mets.xml -----------
N|image|ark:/13030/kt4d5nf2wr
---------- kt4h4nf2j7.mets.xml -----------
N|image|ark:/13030/kt4h4nf2j7
---------- kt4h4nf2kr.mets.xml -----------
N|image|ark:/13030/kt4h4nf2kr
---------- kt4j49r7nf.mets.xml -----------
N|image|ark:/13030/kt4j49r7nf
---------- kt4k403539.mets.xml -----------
N|image|ark:/13030/kt4k403539
---------- kt4k40354t.mets.xml -----------
N|image|ark:/13030/kt4k40354t
---------- kt4m3nf22n.mets.xml -----------
N|image|ark:/13030/kt4m3nf22n
---------- kt4n39r9mj.mets.xml -----------
N|image|ark:/13030/kt4n39r9mj
---------- kt4q2nf0q5.mets.xml -----------
N|image|ark:/13030/kt4q2nf0q5
---------- kt4s2035sz.mets.xml -----------
N|image|ark:/13030/kt4s2035sz
---------- kt4t1nf1n8.mets.xml -----------
N|image|ark:/13030/kt4t1nf1n8
---------- kt4w1035m1.mets.xml -----------
N|image|ark:/13030/kt4w1035m1
---------- kt4w1035nj.mets.xml -----------
N|image|ark:/13030/kt4w1035nj
---------- kt4w1035p2.mets.xml -----------
N|image|ark:/13030/kt4w1035p2
---------- kt4w1035qk.mets.xml -----------
N|image|ark:/13030/kt4w1035qk
---------- kt4x0nf1s0.mets.xml -----------
N|image|ark:/13030/kt4x0nf1s0
---------- kt4x0nf1th.mets.xml -----------
N|image|ark:/13030/kt4x0nf1th
---------- kt4z09r9rk.mets.xml -----------
N|image|ark:/13030/kt4z09r9rk
---------- kt500038s1.mets.xml -----------
N|image|ark:/13030/kt500038s1
---------- kt500038tj.mets.xml -----------
N|image|ark:/13030/kt500038tj
---------- kt500038v2.mets.xml -----------
N|image|ark:/13030/kt500038v2
---------- kt509nf2d6.mets.xml -----------
N|image|ark:/13030/kt509nf2d6
---------- kt5199s02r.mets.xml -----------
N|image|ark:/13030/kt5199s02r
---------- kt5199s038.mets.xml -----------
N|image|ark:/13030/kt5199s038
---------- kt529035m3.mets.xml -----------
N|image|ark:/13030/kt529035m3
---------- kt538nf15r.mets.xml -----------
N|image|ark:/13030/kt538nf15r
---------- kt538nf168.mets.xml -----------
N|image|ark:/13030/kt538nf168
---------- kt5489r9jj.mets.xml -----------
N|image|ark:/13030/kt5489r9jj
---------- kt5489r9k2.mets.xml -----------
N|image|ark:/13030/kt5489r9k2
---------- kt5580372f.mets.xml -----------
N|image|ark:/13030/kt5580372f
---------- kt5580373z.mets.xml -----------
N|image|ark:/13030/kt5580373z
---------- kt5580374g.mets.xml -----------
N|image|ark:/13030/kt5580374g
---------- kt567nf0n5.mets.xml -----------
N|image|ark:/13030/kt567nf0n5
---------- kt567nf0pp.mets.xml -----------
N|image|ark:/13030/kt567nf0pp
---------- kt5b69r9qf.mets.xml -----------
N|image|ark:/13030/kt5b69r9qf
---------- kt5b69r9rz.mets.xml -----------
N|image|ark:/13030/kt5b69r9rz
---------- kt5c6035kj.mets.xml -----------
N|image|ark:/13030/kt5c6035kj
---------- kt5c6035m2.mets.xml -----------
N|image|ark:/13030/kt5c6035m2
---------- kt5d5nf188.mets.xml -----------
N|image|ark:/13030/kt5d5nf188
---------- kt5g5035h5.mets.xml -----------
N|image|ark:/13030/kt5g5035h5
---------- kt5h4nf3j1.mets.xml -----------
N|image|ark:/13030/kt5h4nf3j1
---------- kt5h4nf3kj.mets.xml -----------
N|image|ark:/13030/kt5h4nf3kj
---------- kt5j49s110.mets.xml -----------
N|image|ark:/13030/kt5j49s110
---------- kt5k4035ht.mets.xml -----------
N|image|ark:/13030/kt5k4035ht
---------- kt5k4035jb.mets.xml -----------
N|image|ark:/13030/kt5k4035jb
---------- kt5k4035kv.mets.xml -----------
N|image|ark:/13030/kt5k4035kv
---------- kt5m3nf27j.mets.xml -----------
N|image|ark:/13030/kt5m3nf27j
---------- kt5n39r9c7.mets.xml -----------
N|image|ark:/13030/kt5n39r9c7
---------- kt5n39r9dr.mets.xml -----------
N|image|ark:/13030/kt5n39r9dr
---------- kt5r29r8p2.mets.xml -----------
N|image|ark:/13030/kt5r29r8p2
---------- kt5r29r8qk.mets.xml -----------
N|image|ark:/13030/kt5r29r8qk
---------- kt5s20364x.mets.xml -----------
N|image|ark:/13030/kt5s20364x
---------- kt5t1nf2df.mets.xml -----------
N|image|ark:/13030/kt5t1nf2df
---------- kt5t1nf2fz.mets.xml -----------
N|image|ark:/13030/kt5t1nf2fz
---------- kt5t1nf2gg.mets.xml -----------
N|image|ark:/13030/kt5t1nf2gg
---------- kt5v19r9b1.mets.xml -----------
N|image|ark:/13030/kt5v19r9b1
---------- kt5v19r9cj.mets.xml -----------
N|image|ark:/13030/kt5v19r9cj
---------- kt5w1034sf.mets.xml -----------
N|image|ark:/13030/kt5w1034sf
---------- kt5w1034tz.mets.xml -----------
N|image|ark:/13030/kt5w1034tz
---------- kt5w1034vg.mets.xml -----------
N|image|ark:/13030/kt5w1034vg
---------- kt5x0nf1xc.mets.xml -----------
N|image|ark:/13030/kt5x0nf1xc
---------- kt5x0nf1zw.mets.xml -----------
N|image|ark:/13030/kt5x0nf1zw
---------- kt5z09r9bp.mets.xml -----------
N|image|ark:/13030/kt5z09r9bp
---------- kt6000360g.mets.xml -----------
N|image|ark:/13030/kt6000360g
---------- kt60003610.mets.xml -----------
N|image|ark:/13030/kt60003610
---------- kt6199s2b5.mets.xml -----------
N|image|ark:/13030/kt6199s2b5
---------- kt629034nf.mets.xml -----------
N|image|ark:/13030/kt629034nf
---------- kt629034pz.mets.xml -----------
N|image|ark:/13030/kt629034pz
---------- kt629034qg.mets.xml -----------
N|image|ark:/13030/kt629034qg
---------- kt629034r0.mets.xml -----------
N|image|ark:/13030/kt629034r0
---------- kt638nf32g.mets.xml -----------
N|image|ark:/13030/kt638nf32g
---------- kt658036zq.mets.xml -----------
N|image|ark:/13030/kt658036zq
---------- kt6779r8r4.mets.xml -----------
N|image|ark:/13030/kt6779r8r4
---------- kt6779r8sn.mets.xml -----------
N|image|ark:/13030/kt6779r8sn
---------- kt696nf2bf.mets.xml -----------
N|image|ark:/13030/kt696nf2bf
---------- kt6b69r9m6.mets.xml -----------
N|image|ark:/13030/kt6b69r9m6
---------- kt6c6036sf.mets.xml -----------
N|image|ark:/13030/kt6c6036sf
---------- kt6d5nf41d.mets.xml -----------
N|image|ark:/13030/kt6d5nf41d
---------- kt6g5035qk.mets.xml -----------
N|image|ark:/13030/kt6g5035qk
---------- kt6h4nf40j.mets.xml -----------
N|image|ark:/13030/kt6h4nf40j
---------- kt6j49r8vn.mets.xml -----------
N|image|ark:/13030/kt6j49r8vn
---------- kt6j49r8w5.mets.xml -----------
N|image|ark:/13030/kt6j49r8w5
---------- kt6k4037n5.mets.xml -----------
N|image|ark:/13030/kt6k4037n5
---------- kt6k4037pp.mets.xml -----------
N|image|ark:/13030/kt6k4037pp
---------- kt6m3nf448.mets.xml -----------
N|image|ark:/13030/kt6m3nf448
---------- kt6m3nf45s.mets.xml -----------
N|image|ark:/13030/kt6m3nf45s
---------- kt6n39s05j.mets.xml -----------
N|image|ark:/13030/kt6n39s05j
---------- kt6q2nf44x.mets.xml -----------
N|image|ark:/13030/kt6q2nf44x
---------- kt6s2036zn.mets.xml -----------
N|image|ark:/13030/kt6s2036zn
---------- kt6t1nf2mv.mets.xml -----------
N|image|ark:/13030/kt6t1nf2mv
---------- kt6t1nf2nc.mets.xml -----------
N|image|ark:/13030/kt6t1nf2nc
---------- kt6x0nf426.mets.xml -----------
N|image|ark:/13030/kt6x0nf426
---------- kt6x0nf43q.mets.xml -----------
N|image|ark:/13030/kt6x0nf43q
---------- kt7000373t.mets.xml -----------
N|image|ark:/13030/kt7000373t
---------- kt7000374b.mets.xml -----------
N|image collection|ark:/13030/kt7000374b
---------- kt709nf324.mets.xml -----------
N|image|ark:/13030/kt709nf324
---------- kt7199r928.mets.xml -----------
N|image|ark:/13030/kt7199r928
---------- kt7199r93s.mets.xml -----------
N|image|ark:/13030/kt7199r93s
---------- kt729036hn.mets.xml -----------
N|image|ark:/13030/kt729036hn
---------- kt729036j5.mets.xml -----------
N|image|ark:/13030/kt729036j5
---------- kt738nf5kh.mets.xml -----------
N|image|ark:/13030/kt738nf5kh
---------- kt7489r7xw.mets.xml -----------
N|image|ark:/13030/kt7489r7xw
---------- kt7489r7zd.mets.xml -----------
N|image|ark:/13030/kt7489r7zd
---------- kt75803874.mets.xml -----------
N|image|ark:/13030/kt75803874
---------- kt7580388n.mets.xml -----------
N|image|ark:/13030/kt7580388n
---------- kt767nf2m7.mets.xml -----------
N|image|ark:/13030/kt767nf2m7
---------- kt7779r933.mets.xml -----------
N|image|ark:/13030/kt7779r933
---------- kt7b69r8t4.mets.xml -----------
N|image|ark:/13030/kt7b69r8t4
---------- kt7b69r8vn.mets.xml -----------
N|image|ark:/13030/kt7b69r8vn
---------- kt7c6039k3.mets.xml -----------
N|image|ark:/13030/kt7c6039k3
---------- kt7d5nf469.mets.xml -----------
N|image|ark:/13030/kt7d5nf469
---------- kt7f59s1dn.mets.xml -----------
N|image|ark:/13030/kt7f59s1dn
---------- kt7f59s1f5.mets.xml -----------
N|image|ark:/13030/kt7f59s1f5
---------- kt7f59s1gp.mets.xml -----------
N|image|ark:/13030/kt7f59s1gp
---------- kt7g5036gr.mets.xml -----------
N|image|ark:/13030/kt7g5036gr
---------- kt7j49s166.mets.xml -----------
N|image|ark:/13030/kt7j49s166
---------- kt7k4038b9.mets.xml -----------
N|image|ark:/13030/kt7k4038b9
---------- kt7m3nf3nv.mets.xml -----------
N|image|ark:/13030/kt7m3nf3nv
---------- kt7n39s30q.mets.xml -----------
N|image|ark:/13030/kt7n39s30q
---------- kt7n39s317.mets.xml -----------
N|image|ark:/13030/kt7n39s317
---------- kt7q2nf4bb.mets.xml -----------
N|image|ark:/13030/kt7q2nf4bb
---------- kt7t1nf48z.mets.xml -----------
N|image|ark:/13030/kt7t1nf48z
---------- kt7t1nf49g.mets.xml -----------
N|image|ark:/13030/kt7t1nf49g
---------- kt7v19s13m.mets.xml -----------
N|image|ark:/13030/kt7v19s13m
---------- kt7v19s144.mets.xml -----------
N|image|ark:/13030/kt7v19s144
---------- kt7v19s15n.mets.xml -----------
N|image|ark:/13030/kt7v19s15n
---------- kt7w1038jc.mets.xml -----------
N|image|ark:/13030/kt7w1038jc
---------- kt7w1038kw.mets.xml -----------
N|image|ark:/13030/kt7w1038kw
---------- kt7x0nf6c4.mets.xml -----------
N|image|ark:/13030/kt7x0nf6c4
---------- kt800036v1.mets.xml -----------
N|image|ark:/13030/kt800036v1
---------- kt809nf78g.mets.xml -----------
N|image|ark:/13030/kt809nf78g
---------- kt8199s298.mets.xml -----------
N|image|ark:/13030/kt8199s298
---------- kt8199s2bs.mets.xml -----------
N|image|ark:/13030/kt8199s2bs
---------- kt829038q1.mets.xml -----------
N|image|ark:/13030/kt829038q1
---------- kt8489r969.mets.xml -----------
N|image|ark:/13030/kt8489r969
---------- kt867nf4hz.mets.xml -----------
N|image|ark:/13030/kt867nf4hz
---------- kt867nf4jg.mets.xml -----------
N|image|ark:/13030/kt867nf4jg
---------- kt867nf4k0.mets.xml -----------
N|image|ark:/13030/kt867nf4k0
---------- kt8779s151.mets.xml -----------
N|image|ark:/13030/kt8779s151
---------- kt8779s16j.mets.xml -----------
N|image|ark:/13030/kt8779s16j
---------- kt8779s172.mets.xml -----------
N|image|ark:/13030/kt8779s172
---------- kt88703852.mets.xml -----------
N|image|ark:/13030/kt88703852
---------- kt896nf69g.mets.xml -----------
N|image|ark:/13030/kt896nf69g
---------- kt8b69s103.mets.xml -----------
N|image|ark:/13030/kt8b69s103
---------- kt8c60387r.mets.xml -----------
N|image|ark:/13030/kt8c60387r
---------- kt8d5nf2sf.mets.xml -----------
N|image|ark:/13030/kt8d5nf2sf
---------- kt8f59s16v.mets.xml -----------
N|image|ark:/13030/kt8f59s16v
---------- kt8h4nf4gd.mets.xml -----------
N|image|ark:/13030/kt8h4nf4gd
---------- kt8j49s1mq.mets.xml -----------
N|image|ark:/13030/kt8j49s1mq
---------- kt8k4037fp.mets.xml -----------
N|image|ark:/13030/kt8k4037fp
---------- kt8k4037g6.mets.xml -----------
N|image|ark:/13030/kt8k4037g6
---------- kt8k4037hq.mets.xml -----------
N|image|ark:/13030/kt8k4037hq
---------- kt8m3nf6z8.mets.xml -----------
N|image|ark:/13030/kt8m3nf6z8
---------- kt8m3nf708.mets.xml -----------
N|image|ark:/13030/kt8m3nf708
---------- kt8n39s13m.mets.xml -----------
N|image|ark:/13030/kt8n39s13m
---------- kt8n39s144.mets.xml -----------
N|image|ark:/13030/kt8n39s144
---------- kt8n39s15n.mets.xml -----------
N|image|ark:/13030/kt8n39s15n
---------- kt8n39s165.mets.xml -----------
N|image|ark:/13030/kt8n39s165
---------- kt8q2nf583.mets.xml -----------
N|image|ark:/13030/kt8q2nf583
---------- kt8q2nf59m.mets.xml -----------
N|image|ark:/13030/kt8q2nf59m
---------- kt8r29s2fx.mets.xml -----------
N|image|ark:/13030/kt8r29s2fx
---------- kt8s203818.mets.xml -----------
N|image|ark:/13030/kt8s203818
---------- kt8t1nf54p.mets.xml -----------
N|image|ark:/13030/kt8t1nf54p
---------- kt8t1nf556.mets.xml -----------
N|image|ark:/13030/kt8t1nf556
---------- kt8v19s1v9.mets.xml -----------
N|image|ark:/13030/kt8v19s1v9
---------- kt8v19s1wt.mets.xml -----------
N|image|ark:/13030/kt8v19s1wt
---------- kt8w10377j.mets.xml -----------
N|image|ark:/13030/kt8w10377j
---------- kt8z09s0rx.mets.xml -----------
N|image|ark:/13030/kt8z09s0rx
---------- kt900039qq.mets.xml -----------
N|image|ark:/13030/kt900039qq
---------- kt909nf5t3.mets.xml -----------
N|image|ark:/13030/kt909nf5t3
---------- kt9199s2tb.mets.xml -----------
N|image|ark:/13030/kt9199s2tb
---------- kt929038rv.mets.xml -----------
N|image|ark:/13030/kt929038rv
---------- kt938nf68z.mets.xml -----------
N|image|ark:/13030/kt938nf68z
---------- kt938nf69g.mets.xml -----------
N|image|ark:/13030/kt938nf69g
---------- kt9779s2bd.mets.xml -----------
N|image|ark:/13030/kt9779s2bd
---------- kt9779s2cx.mets.xml -----------
N|image|ark:/13030/kt9779s2cx
---------- kt987039pm.mets.xml -----------
N|image|ark:/13030/kt987039pm
---------- kt996nf65q.mets.xml -----------
N|image|ark:/13030/kt996nf65q
---------- kt996nf667.mets.xml -----------
N|image|ark:/13030/kt996nf667
---------- kt9b69s3bj.mets.xml -----------
N|image|ark:/13030/kt9b69s3bj
---------- kt9c60386j.mets.xml -----------
N|image|ark:/13030/kt9c60386j
---------- kt9f59s20j.mets.xml -----------
N|image|ark:/13030/kt9f59s20j
---------- kt9g5039vh.mets.xml -----------
N|image|ark:/13030/kt9g5039vh
---------- kt9j49s1m1.mets.xml -----------
N|image|ark:/13030/kt9j49s1m1
---------- kt9j49s1nj.mets.xml -----------
N|image|ark:/13030/kt9j49s1nj
---------- kt9k4039k1.mets.xml -----------
N|image|ark:/13030/kt9k4039k1
---------- kt9k4039mj.mets.xml -----------
N|image|ark:/13030/kt9k4039mj
---------- kt9m3nf535.mets.xml -----------
N|image|ark:/13030/kt9m3nf535
---------- kt9n39s0g4.mets.xml -----------
N|image|ark:/13030/kt9n39s0g4
---------- kt9p3038f4.mets.xml -----------
N|image|ark:/13030/kt9p3038f4
---------- kt9p3038gn.mets.xml -----------
N|image|ark:/13030/kt9p3038gn
---------- kt9r29s2wz.mets.xml -----------
N|image|ark:/13030/kt9r29s2wz
---------- kt9t1nf6dm.mets.xml -----------
N|image|ark:/13030/kt9t1nf6dm
---------- kt9v19s0pj.mets.xml -----------
N|image|ark:/13030/kt9v19s0pj
---------- kt9w1039gf.mets.xml -----------
N|image|ark:/13030/kt9w1039gf
---------- kt9z09s3v7.mets.xml -----------
N|image|ark:/13030/kt9z09s3v7

Also, added the new METS files to CVS:

% cd /voro/data/oac-lsta/non-lhdrp/mets
% foreach i (`/bin/ls ../mets.ccber`)
foreach? cvs add $i
foreach? cvs commit -m "Initial file." $i
foreach? end

(Its output was unremarkable, and, so, is not included here.)

% /bin/rm -rf /voro/data/oac-lsta/non-lhdrp/mets.ccber

--------------------------------------------------------------------------------

2009/8/18 4pm MAR

They made their TIFFs available to us via FTP.  I tried to put them on
my PC in "/var/www/mar/cheadle.tiffs":

+-----
|From: Michael Russell 
|Sent: Tuesday, August 18, 2009 4:22 PM
|To: INGEST
|Cc: Adrian Turner
|Subject: Re: LSTA 08-09 UCSB Cheadle Center For Biodiversity & Ecological Restoration Katherine Esau Collection ISSUE=218 PROJ=12
|
|Hi, Adrian.
|
|> Per Laurie's instructions below, are you able to retrieve them?
|
|I visited the "winscp.net" site.  It says that it uses the "sftp" (FTP over SSH)
|protocol.  So, I didn't download and install "winscp.net", but tried the Unix
|"sftp" command.  It didn't work:
|
|114 [mar@pc] /var/www/mar/cheadle.tiffs: sftp lifesci.ucsb.edu
|Connecting to lifesci.ucsb.edu...
|ssh_exchange_identification: Connection closed by remote host
|Couldn't read packet: Connection reset by peer
|115 [mar@pc] /var/www/mar/cheadle.tiffs: 
|
|As a fall back, I tried plain "ftp".  I was able to get on using that technique.
|(Of course, the password travels over the network in clear text, so she should
|probably assume that the account has been compromised.)
|
|Laurie> You will see 6 files: LSTA TIFF1-LSTA TIFF5 and a file called
|Laurie> ccber_0356_TIFF, which is a compound object.
|
|Directories "LSTA TIFF1", "LSTA TIFF2", "LSTA TIFF3", "LSTA TIFF 4", and
|"ccber_0356_TIFF" were empty.  There were three TIFFs in "LSTA TIFF 5",
|which I have fetched:
|
|119 [mar@pc] /var/www/mar/cheadle.tiffs: ftp lifesci.ucsb.edu
|Connected to lifesci.ucsb.edu.
|220 lifesci NcFTPd Server (free educational license) ready.
|Name (lifesci.ucsb.edu:mar): datadrop
|331 User datadrop okay, need password.
|Password:
|230-You are user #1 of 50 simultaneous users allowed.
|230-
|230 Restricted user logged in.
|Remote system type is UNIX.
|Using binary mode to transfer files.
|ftp> pass
|Passive mode on.
|ftp> ls -lR
|227 Entering Passive Mode (128,111,226,5,188,30)
|150 Data connection accepted from 128.48.204.141:46712; transfer starting.
|-rw-------   1 datadrop COREgst   11 Aug 17 14:44 .bash_history
|drwxr-xr-x   2 datadrop COREgst   2048 Aug 18 08:00 LSTA TIFF 4
|drwxr-xr-x   2 datadrop COREgst   1536 Aug 18 08:00 LSTA TIFF 5
|drwxr-xr-x   2 datadrop COREgst   2048 Aug 18 08:00 LSTA TIFF1
|drwxr-xr-x   2 datadrop COREgst   2560 Aug 18 08:00 LSTA TIFF2
|drwxr-xr-x   2 datadrop COREgst   2048 Aug 18 08:00 LSTA TIFF3
|drwxr-xr-x   2 datadrop COREgst   1536 Aug 18 08:00 ccber_0356_TIFF
|
|./LSTA TIFF 4:
|
|./LSTA TIFF 5:
|-rw-r--r--   1 datadrop COREgst     157184 Aug 10 14:40 Thumbs.db
|-rw-r--r--   1 datadrop COREgst   24123288 Aug 10 14:24 ccber_0375.tif
|-rw-r--r--   1 datadrop COREgst   22539308 Aug 10 14:25 ccber_0376.tif
|-rw-r--r--   1 datadrop COREgst   23836532 Aug 10 14:30 ccber_0377.tif
|
|./LSTA TIFF1:
|
|./LSTA TIFF2:
|
|./LSTA TIFF3:
|
|./ccber_0356_TIFF:
|226 Listing completed.
|ftp> cd "LSTA TIFF 5"
|250 "/LSTA TIFF 5" is new cwd.
|ftp> get ccber_0375.tif
|local: ccber_0375.tif remote: ccber_0375.tif
|227 Entering Passive Mode (128,111,226,5,188,51)
|150 Data connection accepted from 128.48.204.141:51521; transfer starting for ccber_0375.tif (24123288 bytes).
|226 Transfer completed.
|24123288 bytes received in 6.54 secs (3604.8 kB/s)
|ftp> get ccber_0376.tif
|local: ccber_0376.tif remote: ccber_0376.tif
|227 Entering Passive Mode (128,111,226,5,188,59)
|150 Data connection accepted from 128.48.204.141:43071; transfer starting for ccber_0376.tif (22539308 bytes).
|226 Transfer completed.
|22539308 bytes received in 7.17 secs (3070.9 kB/s)
|ftp> get ccber_0377.tif
|local: ccber_0377.tif remote: ccber_0377.tif
|227 Entering Passive Mode (128,111,226,5,188,66)
|150 Data connection accepted from 128.48.204.141:57601; transfer starting for ccber_0377.tif (23836532 bytes).
|226 Transfer completed.
|23836532 bytes received in 6.51 secs (3574.4 kB/s)
|ftp> quit
|221 Goodbye.
|120 [mar@pc] /var/www/mar/cheadle.tiffs:
|
|So, to answer your question, yes and no.                                                 Regards, Michael
|________________________________________
|From: CDL Ingest Project [mailto:ingest@cdlib.org] 
|Sent: Monday, August 17, 2009 5:03 PM
|To: Michael Russell
|Subject: LSTA 08-09 -- UCSB Cheadle Center for Biodiversity & Ecological Restoration - Katherine Esau coll... ISSUE=218 PROJ=12
|
|When replying, type your text above this line. 
|________________________________________
|Notification of Issue Change 
|The following changes have been made to this Issue: Appended a Description, Incoming mail: From: adrian.turner@ucop.edu; To: ingest@cdlib.org.
|Project: 	Data Acquisitions 
|Issue: 	LSTA 08-09 -- UCSB Cheadle Center for Biodiversity & Ecological Restoration - Katherine Esau collection 
|Issue Number: 	218 
|
|Priority: 	No choice 	  	Status: 	waiting for it to arrive 
|Date: 	08/17/2009 	  	Time: 	17:03:09 
|Creation Date: 	04/21/2008 	  	Creation Time: 	15:24:56 
|Created By: 	Adrian Turner 	  		
|
|Click here to view Issue in Browser 
|Description:
|Hi Michael --
|
|UCSB Cheadle Center posted their TIFFs in a secure web-accessible
|location, for us to grab. Per Laurie's instructions below, are you able
|to retrieve them? Once we grab them, they have a few more to post and
|for us to grab.
|
|Thanks!
|
|-- Adrian
|
|-----Original Message-----
|From: Laurie Hannah [mailto:hannah@lifesci.ucsb.edu] 
|Sent: Monday, August 17, 2009 4:10 PM
|To: Adrian Turner
|Subject: Tiff files
|
|Hi Adrian,
|Ok I have a method for you to get our TIFFs. I have uploaded them to a
|spot, using WinSCP v. 4.1.9 software. You will need to download the
|software from WinSCP.net in order to log in and go to where they are
|stored. When you have downloaded it, here is the login info.:
|
|Host: lifesci.ucsb.edu
|Username: datadrop
|Password: bqxvr3jx
|
|You will see 6 files: LSTA TIFF1-LSTA TIFF5 and a file called
|ccber_0356_TIFF, which is a compound object. I was only allowed 10 GB
|of storage, so I was not able to upload one more file. It is another
|compound object. So, what I would like is for you to download these,
|and when you are through, I will then delete them and upload the last
|file. I hope this works! Let me know if you have any problems.
|
|Laurie
|
|--
|Laurie Hannah
|Librarian/Archivist
|Cheadle Center for Biodiversity and Ecological Restoration Harder South,
|MS-9615 University of California Santa Barbara, CA 93106-9615
|805-893-2506 FAX 805-893-4222
|ccber.lifesci.ucsb.edu
|Current Assignees: Michael Russell, Brian Tingle, Adrian Turner 
|CC(s): (this edit only) adrian.turner@ucop.edu 
|Issue Information: 
|Frequency: 	discrete submission 	  	METS Profile: 	Supported profile 
|METS Metadata (DMD): 	DC 	  	METS Metadata (AMD): 	DC 
|METS Content File: 	Image (graphic)	  		
|Service: 	Access only 	  	Access Storage Est.: 	1,000 items 
|Submission Agreement Status: 	Received 	  	Submission Agreement #: 	CaStbUCC-001-08 
|Notes: 
|Data Acquisitions: Content Profile Worksheet
|
|* Institutions:
|UCSB, C.H. Muller Library, Cheadle Center for Biodiversity
|and Ecological Restoration
|
|* Project name:
|Katherine Esau Digital Archive of Plant Anatomy
|
|* Funding
|LSTA 2008-2009
|
|* Collection scope/content:
|Consists of over 30 linear feet of archival research materials
|(experimental data, publications, correspondence,
|photographs and negatives, lantern slides, and artifacts) and
|preserved plant specimens and associated
|microscope slides of plant dissections, from which the
|photographs derive.
|
|* Collection formats/genres to digitize:
|Glass and film negatives and scrapbooks
|
|* Collection dates:
|1920s-1970s
|
|* Total number of objects:
|1,000 simple image objects
|
|* Finding aid?:
|- Yes
|
|* Access plans:
|- CONTENTdm (local)
|- Calisphere/OAC
|
|* Preservation plans:
|- None
|
|* Timeline:
|July 2008-June 2009 (completed and ingested in
|OAC/Calisphere)
|
|* Digital object creation tool:
|- CONTENTdm
|
|* Object types/content file formats:
|- Image (TIFF masters, JPEG access and thumbs)
|
|* Metadata types:
|- Dublin Core (DMD/AMD)
|
|* METS Profile:
|- Supported (7Train)
|
|* CDL services sought:
|- Calisphere/OAC only
|
|* CDL parterning strategy suggested:
|- Parter using LHDRP framework
|
|* Contacts:
|Laurie Hannah
|805-893-4211
|hmmah@lifesci.ucsb.edu
|
|* Project proposal info.:
|See attached LSTA 2008-2009 preliminary proposal 
|Attachments: UCSBProposal.pdf lsta0809_message-humboldt-ucsb.txt ucsb_letterofsupport.pdf ucsb_cheadle_dasi.doc 
+-----

--------------------------------------------------------------------------------

2009/8/20 10am MAR

+-----
|From: Adrian Turner 
|Sent: Thursday, August 20, 2009 9:47 AM
|To: Michael Russell
|Subject: FW: LSTA 08-09 UCSB Cheadle Center For Biodiversity & Ecological Restoration Katherine Esau Collection ISSUE=218 PROJ=12
|
|Hi Michael --
| 
|When you have a moment today, would you mind trying to access the TIFFs on UCSB Cheadle Center's site again?
| 
|Thanks!!!
| 
|-- Adrian
|
|________________________________________
|From: Laurie Hannah [mailto:hannah@lifesci.ucsb.edu] 
|Sent: Thursday, August 20, 2009 9:42 AM
|To: Adrian Turner
|Subject: Re: LSTA 08-09 UCSB Cheadle Center For Biodiversity & Ecological Restoration Katherine Esau Collection ISSUE=218 PROJ=12
|Hi Adrian,
|Would you please ask Michael to try to download LSTA TIFF1 as soon as possible?   I have recopied that folder again and I would like to know if he can grab them.  (The other folders he can ignore as they are still empty.) If it works, I will recopy the files again.  Sigh.
|
|Laurie
|
|Adrian Turner wrote: 
|Hi Laurie,
| 
|Michael Russell here at the CDL, who is processing your CONTENTdm objects and TIFFs, just tried to grab the TIFF files you've posted.
| 
|Per Michael, directories "LSTA TIFF1", "LSTA TIFF2", "LSTA TIFF3", "LSTA TIFF 4", and "ccber_0356_TIFF" were empty.  There were three only TIFFs in "LSTA TIFF 5":
| 
|-rw-r--r--   1 datadrop COREgst     157184 Aug 10 14:40 Thumbs.db
|-rw-r--r--   1 datadrop COREgst   24123288 Aug 10 14:24 ccber_0375.tif
|-rw-r--r--   1 datadrop COREgst   22539308 Aug 10 14:25 ccber_0376.tif
|-rw-r--r--   1 datadrop COREgst   23836532 Aug 10 14:30 ccber_0377.tif
| 
|Can you confirm that all of TIFFs you had intended to post are there?
| 
|Thanks,
| 
|-- Adrian
| 
|
|-----Original Message-----
|From: Laurie Hannah [mailto:hannah@lifesci.ucsb.edu] 
|Sent: Monday, August 17, 2009 4:10 PM
|To: Adrian Turner
|Subject: Tiff files
| 
|Hi Adrian,
|Ok I have a method for you to get our TIFFs. I have uploaded them to a
|spot, using WinSCP v. 4.1.9 software. You will need to download the
|software from WinSCP.net in order to log in and go to where they are
|stored. When you have downloaded it, here is the login info.:
| 
|Host: lifesci.ucsb.edu
|Username: datadrop
|Password: bqxvr3jx
| 
|You will see 6 files: LSTA TIFF1-LSTA TIFF5 and a file called
|ccber_0356_TIFF, which is a compound object. I was only allowed 10 GB
|of storage, so I was not able to upload one more file. It is another
|compound object. So, what I would like is for you to download these,
|and when you are through, I will then delete them and upload the last
|file. I hope this works! Let me know if you have any problems.
| 
|Laurie
|
|
|-- 
|Laurie Hannah
|Librarian/Archivist
|Cheadle Center for Biodiversity and Ecological Restoration
|Harder South, MS-9615
|University of California
|Santa Barbara, CA 93106-9615
|805-893-2506  FAX 805-893-4222
|ccber.lifesci.ucsb.edu
+-----

2009/8/20 4:30pm

Several more "ftp" sessions.  Varying files were present at any given
time.  I believe we got all of them onto my PC in "/var/www/mar/cheadle.tiffs"
except for "ccber_0356.tif" and "ccber_0357.tif".
