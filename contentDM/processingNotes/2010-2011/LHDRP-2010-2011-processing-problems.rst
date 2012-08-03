=================================
LHDRP 2010-2011 Processing Notes.
=================================


TIFF INGEST
===========
The disk drive won't mount to my MAC. Need to find place to mount.

7training METS creation
=======================

The following cdm exports 7train'd fine
---------------------------------------

* csfpal.xml
* claphila.xml
* cmp.xml (but needs to change something)
* csarw_kt1k4033vs.xml
* csarw_kt258034d7.xml
* csarw_kt2870359t.xml
* csarw_kt438nf2mn.xml
* csarw_kt5s2036cj.xml
* csarw_kt658037kh.xml
* csumbl.xml
* cto_kt8x0nf6g0.xml

The following exports have problems
-----------------------------------

* cto_kt9z09s5pm.xml  -- Error on line 5449 column 3 of file:/voro/data/oac-lsta/contentdm/2010-2011/cto_kt9z09s5pm.xml:
  SXXP0003: Error reported by XML parser: The element type "record" must be terminated by
  the matching end-tag "</record>".
* cban.xml -- problems with "cban_005 " local id, I will remove the space but should get back into CDM. Quite a few local id's have this problem.
* csalcl.xml --   SXXP0003: Error reported by XML parser: The content of elements must consist of
  well-formed character data or markup.
Transformation failed: Run-time errors were reported
AN EXTRA '<' is in a tag... yech.
* crancuca.xml --- problem with filename
Outputting to: file:////voro/data/oac-lsta/mets/2010-2011/c8154f2b.mets.xml
Outputting to: file:////voro/data/oac-lsta/mets/2010-2011/c8wd3xkn.mets.xml
File name extension was neither ".tif" nor ".jpg" in "CRANCUCA_014".
Processing terminated by xsl:message at line 484 in cdm.xsl
* cstr.xml -- isPartOf[1] ("") does not match pattern.
Processing terminated by xsl:message at line 73 in cdm.xsl
