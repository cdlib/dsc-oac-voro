#! /usr/bin/perl

# ------------------------------------
#
# Project:	OAC
#
# Name:		bad.url.fixing.pl
#
# Function:	The LHDRP items that we were going to put into DPR had already
#		been removed by Califa.  For 4 contributors, fix the URLs to
#		point to what we have in Voro.
#
# Command line parameters:  none.
#
# Input:	Directory "/voro/data/oac-lsta/mets" for the METS XML files to
#		fix.
#
# Output:	Directory "fixed.mets" in the same directory as this script
#		for the fixed METS XML.
#
# Input:	THe METS XML that has already been through VORO is
#		"http://content.cdlib.org/mets/ark:/NNNNN/XXXXXXXX".
#		Based on Apache rewrite rule in the "content.cdlib.org"
#		web site ("/texts/local/conf/httpd.conf"):
#		"RewriteRule ^/mets/ark:/([^/]*)/([^/]*)([^/][^/])/$
#		http://content.cdlib.org/dynaxml/data/$1/$3/$2$3/$2$3.mets.xml",
#		It becomes
#		"http://content.cdlib.org/dyaxml/data/NNNNN/22/XXXXXX.mets.xml".
#		Then, the following rewrite rule:
#		"RewriteRule ^/dynaxml(.*)$
#		"http://content.cdlib.org:8088/xtf0s$1?%{QUERY_STRING}", we
#		change the URL to:
#		"http://content.cdlib.org:8088/xtf0s/data/NNNNN/22/XXXXXX.mets.xml".
#		That server's config file appears to say that such files
#		are fetched from directory
#		lrwxrwxrwx 1 texts texts 10 Jun 21 20:03
#			/texts/resin/webapps/xtf0s -> /texts/xtf
#		or "/texts/xtf/data/NNNNN/22/XXXXXX.mets.xml".
#
# Note:		I used the "assocNN.txt" files in
#		"/voro/data/oac-lsta/workspace/2007xmlExports" to determine
#		the ARK numbers associated with the 4 contributors:
#
#		MARC code	NN
#		csmat		36
#		caarpl		02
#		csb		08
#		cwh		10
#
# Author:	Michael A. Russell
#
# Revision History:
#		2007/7/23 - MAR - Initial writing
#
# ------------------------------------

use warnings;
use strict;
use vars qw(
	$ark_ndx
	$bad_mets
	$c
	$cdl_url
	@contrib_list
	$contrib_ndx
	@file_groups
	$groupid
	$i
	$input_document
	$j
	$k
	$l
	$marc_code
	@mets_files
	@mets_flocats
	$nearby
	$output_dir
	$output_file
	$parser
	$pos
	@processed_hrefs
	$processed_href_value
	$processed_mets
	$processed_mets_dir
	$processed_mets_xml
	$this_ark
	$this_ark_last_2
	$unfixed_href
	$unfixed_mets_xml
	$use_attrib
	);

# Declare subroutine(s) we'll define later.
use subs qw(
	urls_ok
	);

# Get command name for error messages.
$pos = rindex($0, "/");
$c = ($pos > 0) ? substr($0, $pos + 1) : $0;
$nearby = ($pos > 0) ? substr($0, 0, $pos + 1) : "./";
$nearby = "" if ($nearby eq "./");
undef $pos;

# Identify where we'll find the bad METS.
$bad_mets = "/voro/data/oac-lsta/mets";

# Identify the directory that contains the processed METS.  (Our ARK
# numbers are missing their "ark:/13030/" prefix, so we hardcode "13030"
# here.)
$processed_mets_dir = "/texts/xtf/data/13030";

# Identify where we'll put the output METS XML.
$output_dir = $nearby . "fixed.mets";

# Pull in code we'll need.
use XML::LibXML;

# Identify the contributors that have the problem, and the ARK numbers
# of their METS XML files.
@contrib_list = (
	"csmat",
	["kt938nd5r8", "kt45802537", "kt1z09q7d2", "kt5489q90t", "kt8m3nd6dj",
	"kt8779r1pb", "kt8g5029vr", "kt5g5026bm", "kt809nd72x", "kt9870291b",
	"kt200021zv", "kt0c602209", "kt1b69q7m7", "kt3p3025fc", "kt0b69q4zn",
	"kt6f59r0fx", "kt4t1nd1nt", "kt4c6026xf", "kt0779q5td", "kt0v19q5qs",
	"kt129022sj", "kt4d5nd27g", "kt796nd3r0", "kt0t1nc8m0", "kt0199q558",
	"kt6p3028j9", "kt1m3nd0f0", "kt8w102773", "kt8290289c", "kt7q2nd44s",
	"kt2p30233x", "kt4r29q7pt", "kt3g5025c1", "kt25802413", "kt8290288v",
	"kt9j49r1rn", "kt496nd138", "kt9d5nd470", "kt958027gf", "kt967nd533",
	"kt4w1025v6", "kt0s2021jq", "kt0290230t", "kt296nd06q", "kt3b69q8hs",
	"kt696nd2w8", "kt8v19r2tt", "kt5j49r0z1", "kt558026tw", "kt2q2nd1ff",
	"kt0489q5s7", "kt8489q9m2", "kt596nd2h8", "kt5w102597", "kt596nd2js",
	"kt9870292v", "kt6f59r0gf", "kt7b69q95b", "kt3t1nd0dd", "kt7c60294x",
	"kt738nd45c", "kt9q2nd4gk", "kt4b69q8bh", "kt9870293c", "kt896nd6rr",
	"kt7s2026qw", "kt7h4nd4n7", "kt6m3nd3x7", "kt0w1023cr", "kt6b69q9zx",
	"kt4t1nd1pb", "kt8779r1rc", "kt2580242m", "kt4h4nd24k", "kt3s2025dh",
	"kt3n39q7gr", "kt8p3027dc", "kt7v19r1dt", "kt1h4nd056", "kt9m3nd5cv",
	"kt467nd1b7", "kt967nd54m", "kt3k4024k9", "kt2d5nd0tp", "kt2z09q6cc",
	"kt796nd3sh", "kt4x0nd16r", "kt7r29q94f", "kt3v19r05g", "kt9t1nd620",
	"kt938nd5ss", "kt3870239q", "kt3w1026xd", "kt358024nq", "kt2t1nd2g3",
	"kt409nd21r", "kt4f59q8zg", "kt5j49r101", "kt4489q8g8", "kt1p30240j",
	"kt0b69q50n", "kt6j49q9z7", "kt3s2025f1", "kt7w1028z4", "kt3w1026zx",
	"kt5000284r", "kt838nd335", "kt0199q56s", "kt709nd3w3", "kt2199q6hj",
	"kt4j49q88s", "kt8j49r141", "kt209nd0bt", "kt0x0nd0xw", "kt6f59r0k0",
	"kt8p3027fw", "kt438nd1mq", "kt4r29q7qb", "kt6199r1qx", "kt9m3nd5dc",
	"kt3n39q7js", "kt4w1025wq", "kt9c6028d6", "kt9p30281g", "kt167nc8sz",
	"kt967nd554", "kt9g5028t2", "kt7j49r199", "kt0j49q6dn", "kt9d5nd48h",
	"kt2n39q8p1", "kt0g502262", "kt7w102904", "kt58702667", "kt267nd09m",
	"kt3j49q8n5", "kt8g5029xs", "kt8j49r13h", "kt1p302412", "kt4j49q86r",
	"kt7q2nd459", "kt9n39r0xd", "kt9z09r3zb", "kt667nd23q", "kt6v19r0sq",
	"kt167nc8rf", "kt738nd46w", "kt6z09r120", "kt9870294w", "kt0580227m",
	"kt9s2029wj", "kt9f59r1sh", "kt6w1028f2", "kt22902482", "kt0x0nd0vv",
	"kt3v19r04z", "kt9489r1gw", "kt609nd40t", "kt8580281w", "kt9p30280z",
	"kt0j49q6f5", "kt1j49q4t6", "kt5c60269f", "kt4r29q7rv", "kt6f59r0hz",
	"kt4j49q878", "kt7f59r0c6", "kt509nd2h9", "kt558026vd", "kt287023z7",
	"kt958027hz", "kt6f59r0jg", "kt8489q9nk", "kt0r29q6m2", "kt7h4nd4pr",
	"kt6489q9x3", "kt9s2029x2", "kt3n39q7h8", "kt0x0nd0wc", "kt1s20234s",
	"kt5q2nd2wk", "kt3d5nd165", "kt9k4029m3", "kt8779r1qv", "kt8c6027wn",
	"kt0x0nd0tb", "kt7p3026h4", "kt5z09q8ds", "kt4v19q9kw", "kt2b69q7df",
	"kt3g5025dj", "kt2p30234f", "kt4q2nd1mn", "kt6489q9wk", "kt6779q8mm",
	"kt8m3nd6f2", "kt9489r1fc", "kt0k4022r0", "kt8s20287x", "kt0m3nc891",
	"kt5j49r0xh", "kt3489q8j0", "kt038nc8ft", "kt1b69q7nr", "kt1779q5q5",
	"kt2t1nd2fk", "kt2w1023t3", "kt2g502522", "kt3x0nd1v8", "kt1h4nd04p",
	"kt8h4nd548", "kt4v19q9jc", "kt1199q673", "kt6199r1pd", "kt8h4nd55s",
	"kt9x0nd5rh", "kt8g5029w8", "kt6x0nd4sm", "kt467nd19q", "kt3k4024js",
	"kt92902953", "kt2c602460", "kt6870261z", "kt5t1nd2m3", "kt1r29q7f8",
	"kt0z09q49r", "kt1v19q6nj", "kt5k40267q", "kt3779q8wt", "kt8k4027tx",
	"kt6580260s", "kt2c60247h"],

	"caarpl",
	["kt7p30279h", "kt4290259p", "kt5779r0gt", "kt200022kn", "kt687026vc",
	"kt0s20223g", "kt9580288t", "kt1580235c", "kt1j49q5rn", "kt367nd32r",
	"kt667nd30n", "kt6199r2pw", "kt8j49r1m8", "kt2h4nd1q8", "kt096nd01h",
	"kt1p302543", "kt1g5025w5", "kt387023v0", "kt109nc96b", "kt8199r289",
	"kt9d5nd56z", "kt3j49q9ch", "kt8c6028sk", "kt1489q866", "kt0000232r",
	"kt929029qc", "kt0k4023wj", "kt109nc9df", "kt2k4024rk", "kt467nd254",
	"kt4779q947", "kt6199r2z1", "kt0t1nc9q1", "kt296nd124", "kt5h4nd4d0",
	"kt5580282g", "kt8489r0np", "kt8779r2tw", "kt8s2029bz", "kt1h4nd145",
	"kt638nd4sc", "kt6n39r1cp", "kt696nd3s6", "kt9779r44t", "kt4q2nd2p5",
	"kt4z09r0zb", "kt3t1nd1hf", "kt4g50269s", "kt2q2nd2gf", "kt7j49r288",
	"kt8b69r30m", "kt9q2nd5ch", "kt2j49q7h9", "kt9p302930", "kt5t1nd3zr",
	"kt4v19r0s3", "kt500029kz", "kt1n39q6k6", "kt1j49q5x7", "kt338nd213",
	"kt100025m9", "kt6z09r2k7", "kt9k4030p7", "kt7m3nd5jt", "kt1b69q88j",
	"kt300024tj", "kt4k4026nm", "kt2v19q7wz", "kt8j49r24h", "kt500029mg",
	"kt6580277w", "kt500029n0", "kt8m3nd77f", "kt7w1029nz", "kt4n39r01d",
	"kt7b69r07g", "kt6r29r1kf", "kt6489r12r", "kt1p3025fr", "kt9779r45b",
	"kt9b69r4dm", "kt167nc9sf", "kt667nd399", "kt3d5nd254", "kt2t1nd34d",
	"kt7489q9f5", "kt0b69q61n", "kt1k4024r8", "kt0g5023c4", "kt167nc9tz",
	"kt3n39q910", "kt396nd29j", "kt100025nt", "kt8q2nd6vx", "kt8n39r2gb",
	"kt5489r061", "kt6580278d", "kt396nd281", "kt5n39r0tm", "kt196nc8r3",
	"kt0v19q6jp", "kt2x0nd0kb", "kt6779q9d0", "kt7g502801", "kt0t1nc9gd",
	"kt4d5nd30b", "kt9h4nd5js", "kt3h4nd3dw", "kt7c60300z", "kt709nd4kx",
	"kt638nd4f6", "kt7p3027b1", "kt0k4023gb", "kt6x0nd5bc", "kt7s2027nb",
	"kt396nd1wv", "kt8199r29t", "kt558027m8", "kt5g5026ww", "kt8j49r1ns",
	"kt0580234j", "kt5s2026mq", "kt8489r0d2", "kt9v19r24s", "kt7f59r19n",
	"kt2j49q76n", "kt3m3nd09j", "kt0779q6jr", "kt5779r0hb", "kt7199r081",
	"kt138nd1ms", "kt9d5nd57g", "kt4z09r0j4", "kt209nd11n", "kt487025ws",
	"kt6m3nd4qm", "kt4m3nd3bt", "kt2w1024hx", "kt0n39q6kw", "kt9z09r4jm",
	"kt9199r362", "kt3m3nd0b2", "kt0r29q78c", "kt6n39r0z0", "kt4r29q8cn",
	"kt7q2nd548", "kt7w1029db", "kt5g5026xd", "kt4j49q967", "kt6g5027bd",
	"kt296nd0w2", "kt0c6022s6", "kt7s2027pv", "kt329024bd", "kt558027ns",
	"kt6f59r1kg", "kt8z09r1sg", "kt3r29q8gw", "kt1g5025xp", "kt0v19q6k6",
	"kt7g50281j", "kt509nd37n", "kt238nd21s", "kt7t1nd5np", "kt0p3023cf",
	"kt0199q5z5", "kt8779r2jr", "kt3t1nd0zp", "kt6v19r1h2", "kt558027p9",
	"kt6m3nd4r4", "kt4r29q8d5", "kt4489q98n", "kt5r29q9z7", "kt6w10295d",
	"kt829028z6", "kt609nd4r6", "kt3n39q8j8", "kt709nd4mf", "kt029023w8",
	"kt0b69q5sj", "kt4q2nd2j3", "kt8k4028d6", "kt6p3029bp", "kt4c6027sv",
	"kt938nd6mp", "kt338nd1qz", "kt3g50263c", "kt7v19r287", "kt0m3nc93d",
	"kt3j49q9fj", "kt7n39r3n3", "kt296nd0xk", "kt538nd248", "kt7q2nd55s",
	"kt3w1027kq", "kt9g5029tj", "kt0z09q4wj", "kt3h4nd3fd"],

	"csb",
	["kt3w1027xw", "kt7w1029pg", "kt267nd1bm", "kt7n39r45b", "kt429025hs",
	"kt5580284h", "kt1m3nd17c", "kt138nd1qb", "kt5870272n", "kt4m3nd3mz",
	"kt4d5nd3c1", "kt2j49q7jt", "kt6b69r1b6", "kt9f59r2zk", "kt2779q6gb",
	"kt2c6025dk", "kt0j49q7b3", "kt2s2025g7", "kt0c60235c", "kt5r29r09h",
	"kt1n39q6mq", "kt8p3028gw", "kt887029gr", "kt1q2nd061", "kt3s2026g1",
	"kt6p3029pv", "kt7d5nd5k1", "kt9x0nd6hc", "kt6580279x", "kt4f59q9wx",
	"kt6n39r1d6", "kt096nd07m", "kt6z09r2mr", "kt7f59r1td", "kt6199r301",
	"kt458025z5", "kt1w1024kn", "kt2d5nd1sn", "kt3q2nd0xh", "kt2t1nd35x",
	"kt9m3nd678", "kt7c60305j", "kt987030g5", "kt9k4030qr", "kt867nd5s4",
	"kt1w1024m5", "kt3n39q92h", "kt2d5nd1t5", "kt1t1nd0hb", "kt7k402968",
	"kt1p30259p", "kt2q2nd2cw", "kt3d5nd1x1", "kt3p3026ct", "kt4n39q9t6",
	"kt2n39q9q1", "kt9j49r2m2", "kt9c602994", "kt8z09r1vh", "kt467nd22k",
	"kt009nc8h6", "kt0q2nd0fb", "kt9p3028wd", "kt1q2nd040", "kt196nc8xp",
	"kt7z09r3zq", "kt1p3025b6", "kt367nd38v", "kt238nd23t", "kt2s2025fq",
	"kt98703082", "kt5g50272z", "kt7v19r2cs", "kt8t1nd5tk", "kt4d5nd33w",
	"kt6j49r0qq", "kt5199r1bx", "kt2p3023s8", "kt3h4nd3kg", "kt2h4nd1wv",
	"kt5290271t", "kt4d5nd34d", "kt2h4nd1xc", "kt3t1nd179", "kt709nd4q0",
	"kt938nd6q7", "kt5v19q9wv", "kt9r29r4b6", "kt4870264w", "kt209nd15q",
	"kt196nc8z6", "kt5b69q9s1", "kt3489q9dd", "kt6b69r15m", "kt287024wp",
	"kt0870224q", "kt609nd4w8", "kt258024kc", "kt5779r0mw", "kt5779r0nd",
	"kt4r29q8j7", "kt2c6025bj", "kt3t1nd18t", "kt838nd403", "kt209nd167",
	"kt238nd24b", "kt4g502625", "kt9z09r4mn", "kt638nd4k8", "kt9779r3wq",
	"kt6s2027q2", "kt338nd1x2", "kt438nd2g4", "kt496nd21q", "kt9g5029x3",
	"kt1j49q5wq", "kt0k4023nx", "kt0h4nd1j2", "kt9f59r2s0", "kt0z09q534",
	"kt2g5025sx", "kt3p3026db", "kt1489q8d9", "kt9p3028xx", "kt9n39r1p8",
	"kt7g50285m", "kt309nd2kq", "kt0p3023hh", "kt8p30288s", "kt0h4nd1kk",
	"kt8q2nd6pb", "kt2f59q8h4", "kt338nd1zk", "kt0n39q6qz", "kt9199r37k",
	"kt2x0nd0rx", "kt8k4028g7", "kt3k4025fq", "kt3w1027r9", "kt996nd658",
	"kt6z09r293", "kt2x0nd0sf", "kt5s2026tt", "kt709nd4rh", "kt7s2027vf",
	"kt3z09q9c4", "kt6k4027r8", "kt4t1nd2ms", "kt5g50273g", "kt8s20295c",
	"kt1779q6p4", "kt4n39q9vq", "kt8r29r2r4", "kt100025fq", "kt3j49q9j3",
	"kt1580238x", "kt7g502864", "kt6d5nd4q9", "kt0q2nd0gv", "kt0f59q6p4",
	"kt0s202261", "kt0s20227j", "kt8j49r1vw", "kt2b69q86t", "kt2g5025tf",
	"kt196nc906", "kt38702412", "kt709nd4s1", "kt700026s7", "kt1p3025cq",
	"kt9k4030g4", "kt0580238m", "kt2b69q87b", "kt5n39r0gf", "kt1z09q8bh",
	"kt4d5nd35x", "kt9z09r4n5", "kt3n39q8rc", "kt787028ff", "kt4v19r0k0",
	"kt4h4nd2wz", "kt1v19q7pj", "kt9s2030zp", "kt787028gz", "kt5r29r04x",
	"kt4h4nd2xg", "kt538nd2cw", "kt8r29r2sn", "kt8c6028z5", "kt867nd5fz",
	"kt4r29q8kr", "kt500029cv", "kt9w1029w6", "kt3h4nd3m0", "kt1489q8ft",
	"kt200022xt", "kt3779q9xt", "kt196nc91q", "kt4s20269r", "kt0d5nd0sj"],

	"cwh",
	["kt7n39r3zr", "kt9c6029bn", "kt1r29q885", "kt8p3028cb", "kt738nd56c",
	"kt3k4025j8", "kt4489q9h8", "kt209nd188", "kt958028jz", "kt8f59r1x8",
	"kt567nd23d", "kt8t1nd5v3", "kt3f59q8z5", "kt1t1nd0ds", "kt096nd021",
	"kt2n39q9s2", "kt3t1nd19b", "kt4p30266j", "kt9f59r2v1", "kt3b69q9c6",
	"kt3k4025ks", "kt809nd7kp", "kt9489r2tj", "kt9199r39m", "kt100025g7",
	"kt9h4nd5rw", "kt4b69q98z", "kt6q2nd62d", "kt358025h4", "kt438nd2kp",
	"kt209nd19s", "kt6779q9kk", "kt3m3nd0g4", "kt867nd5gg", "kt2w1024rj",
	"kt5779r0qf", "kt858028k5", "kt629026hw", "kt5d5nd3cb", "kt7f59r1ks",
	"kt7199r0kp", "kt129023v2", "kt709nd4v2", "kt8g5030zd", "kt2v19q7tx",
	"kt458025sk", "kt7n39r40r", "kt6j49r0r7", "kt0000236t", "kt1g50263r",
	"kt9t1nd76j", "kt7n39r418", "kt2p3023ts", "kt538nd2gf", "kt8n39r27q",
	"kt6x0nd5hz", "kt409nd338", "kt6w1029ch", "kt238nd26c", "kt2q2nd2fx",
	"kt2000230b", "kt2n39q9tk", "kt629026jd", "kt9c6029c5", "kt287024x6",
	"kt8r29r2t5", "kt7v19r2ft", "kt7r29r02h", "kt8290291q", "kt9s20310p",
	"kt2779q6d9", "kt5d5nd3dv", "kt5k40274n", "kt1s20241q", "kt638nd4ms",
	"kt3m3nd0hn", "kt809nd7m6", "kt6f59r1xn", "kt3f59q905", "kt396nd23f",
	"kt396nd24z", "kt4k40269f", "kt3b69q9dq", "kt4s2026b8", "kt3t1nd1bv",
	"kt5489r02z", "kt0h4nd1m3", "kt667nd36r", "kt6g5027gg", "kt7f59r1m9",
	"kt4p302672", "kt5c60275v", "kt8f59r1zs", "kt0779q6qb", "kt909nd706",
	"kt1v19q7q2", "kt2p3023v9", "kt838nd424", "kt496nd227", "kt7d5nd5fz",
	"kt9199r3b4", "kt5k402755", "kt067nd0f2", "kt2v19q7vf", "kt4870266x",
	"kt6870270x", "kt938nd6rr", "kt2z09q7fw", "kt4d5nd36f", "kt900029zw",
	"kt996nd679", "kt629026kx", "kt0779q6rv", "kt2r29q8f2", "kt5g502740",
	"kt667nd378", "kt6r29r1gw", "kt0290242b", "kt2b69q89c", "kt5199r1cf",
	"kt2x0nd0tz", "kt1r29q89p", "kt8n39r287", "kt2n39q9v3", "kt2p3023wt",
	"kt8n39r29r", "kt458025t3", "kt800027zm", "kt4k4026bz", "kt109nc99w",
	"kt5n39r0hz", "kt858028mp", "kt1779q6qn", "kt2m3nd212", "kt4n39q9z8",
	"kt6580271s", "kt1199q79m", "kt596nd3b5", "kt9r29r4cq", "kt3199q9nc",
	"kt5199r1dz", "kt6q2nd63x", "kt838nd43n", "kt1w1024hm", "kt9z09r4rq",
	"kt4z09r0sr", "kt0v19q6n7", "kt4k4026cg", "kt738nd57w", "kt3j49q9p5",
	"kt2c6025c2", "kt0z09q555", "kt4d5nd37z", "kt896nd7kn", "kt9489r2v2",
	"kt7f59r1nt", "kt700026v8", "kt8g50310d", "kt7r29r031", "kt1r29q8b6",
	"kt4p30268k", "kt1q2nd05h", "kt2489q7kq", "kt287024zq", "kt4s2026cs",
	"kt8j49r1zf", "kt1k4024p7", "kt238nd27w", "kt2b69q8bw", "kt638nd4n9",
	"kt267nd193", "kt209nd1b9", "kt5199r1fg", "kt338nd20k", "kt5q2nd3vj",
	"kt5c60276c", "kt5z09q9jb", "kt209nd1ct", "kt1489q8gb", "kt0199q647",
	"kt7779r048", "kt2000231v", "kt3g50269g", "kt9g5029zm", "kt8g50311x",
	"kt8g50312f", "kt1d5nd09m", "kt6489r10q", "kt3779r00z", "kt167nc9rx",
	"kt0s202282", "kt5h4nd4bz", "kt238nd28d", "kt1s202427", "kt7p3027hm",
	"kt3d5nd1zj", "kt967nd5z1", "kt300024s1", "kt0x0nd1mq", "kt8s20296w",
	"kt8d5nd4qx", "kt2z09q7gd", "kt109nc9bd", "kt5j49r1zh", "kt4s2026jc"]
	);

# Create the parser outside the loop.
$parser = XML::LibXML->new( );

# Process each contributor.
for ($contrib_ndx = 0; $contrib_ndx < scalar(@contrib_list);
	$contrib_ndx += 2) {

	# Pull out the contributor's MARK code.
	$marc_code = $contrib_list[$contrib_ndx];

	# Process each ARK number for that contributor.
	for ($ark_ndx = 0;
		$ark_ndx < scalar(@{$contrib_list[$contrib_ndx + 1]});
		$ark_ndx++) {

		# Pull out the ARK number.
		$this_ark = ${$contrib_list[$contrib_ndx + 1]}[$ark_ndx];

		# Construct the path to the processed METS XML.
		unless ($this_ark =~ /^[a-z0-9]+([a-z0-9]{2})$/) {
			die "$c:  format of ARK number \"$this_ark\" for ",
				"contributor $marc_code (number $ark_ndx) is ",
				"invalid, stopped";
			}
		$this_ark_last_2 = $1;

		# Construct the name of the input file of the METS XML to
		# fix.
		$unfixed_mets_xml = "$bad_mets/$this_ark.mets.xml";

		# Parse it.
		eval {
			$input_document =
				$parser->parse_file($unfixed_mets_xml);
			};
		if (length($@) != 0) {
			die "$c:  attempt to parse \"$unfixed_mets_xml\", ",
				"$@, stopped";
			}

		# Construct the name of the processed METS XML.
		$processed_mets_xml = "$processed_mets_dir/$this_ark_last_2/" .
			"$this_ark/$this_ark.mets.xml";

		# Parse it.
		eval {
			$processed_mets =
				$parser->parse_file($processed_mets_xml);
			};
		if (length($@) != 0) {
			die "$c:  attempt to parse \"$processed_mets_xml\", ",
				"$@, stopped";
			}

		# Find the file groups.
		@file_groups = $input_document->findnodes(
			"/mets:mets/mets:fileSec/mets:fileGrp");

		# If found none, complain.
		unless (scalar(@file_groups) > 0) {
			print STDERR "$c:  found no \"fileGrp\" in ",
				"contributor $marc_code file $this_ark - ",
				"skipping it\n";
			next;
			}

		# Process each file group.
		for ($i = 0; $i < scalar(@file_groups); $i++) {
			# Get the USE attribute value.
			$use_attrib = $file_groups[$i]->getAttribute("USE");
			unless (defined($use_attrib) &&
				(length($use_attrib) > 0)) {
				print STDERR "$c:  no USE attribute for ",
					"fileGrp at index $i of $marc_code ",
					"$this_ark - skipping it\n";
				next;
				}

			# Get the "mets:file" ones inside that.
			@mets_files = $file_groups[$i]->findnodes("mets:file");
			# If there aren't any, it's probably an error.
			if (scalar(@mets_files) == 0) {
				print STDERR "$c:  no \"mets:file\" within ",
					"fileGrp at index $i of $marc_code ",
					"$this_ark - skipping it\n";
				next;
				}

			# If there is just one, then we don't need to
			# differentiate baed on the GROUPID.
			if (scalar(@mets_files) == 1) {

				# Get the "FLocat"s.
				@mets_flocats = $mets_files[0]->
					findnodes("mets:FLocat");
				if (scalar(@mets_flocats) == 0) {
					print STDERR "$c:  no FLocats in ",
						"\"NO GROUP\" $use_attrib ",
						"$marc_code $this_ark - ",
						"skipping it\n";
					next;
					}

				# Process each one.
				for ($k = 0; $k < scalar(@mets_flocats); $k++) {
					$unfixed_href = $mets_flocats[$k]->
						getAttribute("xlink:href");
					unless (defined($unfixed_href) &&
						(length($unfixed_href) > 0)) {
print STDERR "$c:  no xlink:href in FLocat index $k \"NO GROUP\" $use_attrib ",
"$marc_code $this_ark - skipping it\n";
next;
						}

					# If it's a CDL URL, it's OK.
					if ($unfixed_href =~
						m|^http://[A-Za-z0-9]+\.cdlib\.org|) {
						next;
						}

					# Find the corresponding href in the
					# processed XML.
					@processed_hrefs = $processed_mets->
						findnodes("/mets:mets" .
						"/mets:fileSec" .
						"/mets:fileGrp" .
						"[\@USE='$use_attrib']" .
						"/mets:file" .
						"/mets:FLocat/\@xlink:href");
					unless (scalar(@processed_hrefs) > 0) {
						print STDERR "$c:  found no ",
							"\"href\" attributes ",
							"in processed METS ",
							"XML for \"NO GROUP\" ",
							"$marc_code $this_ark ",
							"$use_attrib - ",
							"skipping it\n";
						next;
						}

					undef $cdl_url;
					for ($l = 0;
						$l < scalar(@processed_hrefs);
						$l++) {
						$cdl_url = $processed_hrefs[$l]
							->getValue( );
						next unless (defined($cdl_url));
						last if ($cdl_url =~
							m|^http://[A-Za-z0-9]+\.cdlib\.org|);
						undef $cdl_url;
						}
					unless (defined($cdl_url)) {
						print STDERR "$c:  unable to ",
							"find a CDL URL in ",
							"the \"href\"s for ",
							"\"NO GROUP\" ",
							"$marc_code ARK ",
							"$this_ark USE ",
							"$use_attrib in the ",
							"processed XML - ",
							"skipping this one\n";
						next;
						}

					# Replace the bad URL with the one good.
					$mets_flocats[$k]->setAttribute(
						"xlink:href", $cdl_url);
					}
				next;
				}

			# There are more than one.  Process each one.
			for ($j = 0; $j < scalar(@mets_files); $j++) {
				# Get the GROUPID attribute value.
				$groupid = $mets_files[$j]->
					getAttribute("GROUPID");
				unless (defined($groupid) &&
					(length($groupid) > 0)) {
unless (urls_ok($mets_files[$j])) {
					print STDERR "$c:  no GROUPID ",
						"attribute for file index $j ",
						"in USE $use_attrib for ",
						"$marc_code $this_ark - ",
						"skipping it\n";
}
					next;
					}

				# Get the "FLocat"s.
				@mets_flocats = $mets_files[$j]->
					findnodes("mets:FLocat");
				if (scalar(@mets_flocats) == 0) {
					print STDERR "$c:  no FLocats in ",
						"$groupid $use_attrib ",
						"$marc_code $this_ark - ",
						"skipping it\n";
					next;
					}

				# Process each one.
				for ($k = 0; $k < scalar(@mets_flocats); $k++) {
					$unfixed_href = $mets_flocats[$k]->
						getAttribute("xlink:href");
					unless (defined($unfixed_href) &&
						(length($unfixed_href) > 0)) {
print STDERR "$c:  no xlink:href in FLocat index $k $groupid $use_attrib ",
"$marc_code $this_ark - skipping it\n";
next;
						}

					# If it's a CDL URL, it's OK.
					if ($unfixed_href =~
						m|^http://[A-Za-z0-9]+\.cdlib\.org|) {
						next;
						}

					# Find the corresponding href in the
					# processed XML.
					@processed_hrefs = $processed_mets->
						findnodes("/mets:mets" .
						"/mets:fileSec" .
						"/mets:fileGrp" .
						"[\@USE='$use_attrib']" .
						"/mets:file" .
						"[\@GROUPID='$groupid']" .
						"/mets:FLocat/\@xlink:href");
					unless (scalar(@processed_hrefs) > 0) {
						print STDERR "$c:  found no ",
							"\"href\" attributes ",
							"in processed METS ",
							"XML for $groupid ",
							"$marc_code $this_ark ",
							"$use_attrib - ",
							"skipping it\n";
						next;
						}



					undef $cdl_url;
					for ($l = 0;
						$l < scalar(@processed_hrefs);
						$l++) {
						$cdl_url = $processed_hrefs[$l]
							->getValue( );
						next unless (defined($cdl_url));
						last if ($cdl_url =~
							m|^http://[A-Za-z0-9]+\.cdlib\.org|);
						undef $cdl_url;
						}
					unless (defined($cdl_url)) {
						print STDERR "$c:  unable to ",
							"find a CDL URL in ",
							"the \"href\"s for ",
							"$groupid ",
							"$marc_code ARK ",
							"$this_ark USE ",
							"$use_attrib in the ",
							"processed XML - ",
							"skipping this one\n";
						next;
						}

					# Replace the bad URL with the one good.
					$mets_flocats[$k]->setAttribute(
						"xlink:href", $cdl_url);

					}
				}
			}

		# Write the fixed XML out.
		$output_file = "$output_dir/$marc_code/$this_ark.mets.xml";
		$input_document->toFile($output_file);
		}
	}

# -----
# Subroutine to verify that all URLs inside the "mets:file" are CDL URLs.
sub urls_ok {
	my $mets_file = $_[0];

	my @xlink_href = $mets_file->findnodes("mets:FLocat/\@xlink:href");
	my $an_href;
	foreach (@xlink_href) {
		$an_href = $_->getValue( );
		next unless (defined($an_href) && (length($an_href) > 0));
		if ($an_href !~ m|^http://[A-Za-z0-9]+\.cdlib\.org|) {
			return(0);
			}
		}

	return(1);
	}
