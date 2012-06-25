2009/7/1 12:30pm MAR

To process the Muir contentdm file, execute:

cd /voro/data/oac-lsta/non-lhdrp/bin
./transform_muir_contentdm.pl ../contentdm/cdm_ucb-uop.xml ../contentdm/transformed_cdm_ucb-uop.xml
./preprocess.pl ../contentdm/transformed_cdm_ucb-uop.xml ../contentdm/preprocessed_cdm_ucb-uop.xml cstoc_kt0w1031nc_
./run_7train.pl ../contentdm/preprocessed_cdm_ucb-uop.xml

--------------------------------------------------------------------------------

2009/7/2 2pm MAR

Repeat the above, after changing the "transform_muir_contentdm.pl" script.

--------------------------------------------------------------------------------

2009/8/18 4:45pm MAR

A new version of the contentdm export file is ready.  Details on it are
on "voro-s10stg.cdlib.org" as:

-rw-r--r--   1 voro     voro        8115 Aug 18 17:34 /voro/workspace/ingest.ticket.206/README.2.txt

Modified script on "voro.cdlib.org":

-rwxrwxr-x   1 voro     voro        3646 Aug 18 17:29 /voro/data/oac-lsta/non-lhdrp/bin/transform_muir_contentdm.pl

to change "br"s to "<br/>" in "<pagetext>" elements.

Reran the sequence of commands:

cd /voro/data/oac-lsta/non-lhdrp/bin
./transform_muir_contentdm.pl ../contentdm/cdm_ucb-uop.xml ../contentdm/transformed_cdm_ucb-uop.xml
./preprocess.pl ../contentdm/transformed_cdm_ucb-uop.xml ../contentdm/preprocessed_cdm_ucb-uop.xml cstoc_kt0w1031nc_
./run_7train.pl ../contentdm/preprocessed_cdm_ucb-uop.xml

--------------------------------------------------------------------------------

2009/8/18 6:15pm MAR

7train is removing the "<br/>"s in the "<pagetext>" when it creates the
"<transcription>" elements.  Remove the preprocessing of the "<pagetext>"
elements in the contentdm exports files from "transform_muir_contentdm.pl",
and create a new script that postprocesses "<transcription>" elements in the
METS.

Now, the sequence of commands is:

cd /voro/data/oac-lsta/non-lhdrp/bin
./transform_muir_contentdm.pl ../contentdm/cdm_ucb-uop.xml ../contentdm/transformed_cdm_ucb-uop.xml
./preprocess.pl ../contentdm/transformed_cdm_ucb-uop.xml ../contentdm/preprocessed_cdm_ucb-uop.xml cstoc_kt0w1031nc_
./run_7train.pl ../contentdm/preprocessed_cdm_ucb-uop.xml
./postprocess_muir_mets.pl

--------------------------------------------------------------------------------

2009/9/1 2:45pm MAR

+-----
|From: Brian Tingle 
|Sent: Tuesday, September 01, 2009 2:13 PM
|To: Michael Russell; Adrian Turner
|Subject: FW: UCB Bancroft Library/University of the Pacific -- Muir letters collection ISSUE=206 PROJ=12
|
|Hi Michael,
|
|Can you take care of this request, and resubmit the METS to production?  Thanks -- Brian
|
|________________________________________
|From: CDL Ingest Project [mailto:ingest@cdlib.org] 
|Sent: Tuesday, September 01, 2009 2:06 PM
|To: Brian Tingle
|Subject: UCB Bancroft Library/University of the Pacific -- Muir letters collection ISSUE=206 PROJ=12
|
|When replying, type your text above this line. 
|________________________________________
|Notification of Issue Change 
|The following changes have been made to this Issue: Appended a Description, Incoming mail: From: adrian.turner@ucop.edu; To: INGEST@ucop.edu.
|Project: 	Data Acquisitions 
|Issue: 	UCB Bancroft Library/University of the Pacific -- Muir letters collection 
|Issue Number: 	206 
|
|Priority: 	No choice 	  	Status: 	working on processing 
|Date: 	09/01/2009 	  	Time: 	14:06:07 
|Creation Date: 	11/28/2007 	  	Creation Time: 	20:15:22 
|Created By: 	Adrian Turner 	  		
|
|Click here to view Issue in Browser 
|Description:
|Thanks, Brian.
|
|Yikes, Shan at UoP (who has been doing all of the CONTENTdm work) is out
|of the office on sabbatical -- and is technically out through 12/21.
|Could we globally update the <relation> URLs file from this:
|http://ark.cdlib.org/ark:/13030/kt0w1031nc
|<http://ark.cdlib.org/ark:/13030/kt0w1031nc> 
|
|... to this:
|
|http://www.oac.cdlib.org/findaid/ark:/13030/kt0w1031nc
|<http://www.oac.cdlib.org/findaid/ark:/13030/kt0w1031nc> 
|
|He could then perhaps make these same changes in CONTENT once he's back
|in the saddle, so the changes are in alignment.
|
|Thanks,
|
|-- Adrian
|Current Assignees: Michael Russell, Brian Tingle, Adrian Turner 
|CC(s): (this edit only) adrian.turner@ucop.edu 
|Issue Information: 
|Frequency: 	discrete submission 	  	METS Profile: 	Supported profile 
|METS Metadata (DMD): 	DC 	  	METS Metadata (AMD): 	DC 
|METS Content File: 	PDF	  		
|Service: 	Unknown 	  	Access Storage Est.: 	ca. 15,000 
|Submission Agreement Status: 	Unknown 	  	  	  
|Notes: 
|===========================================
|Data Acquisitions: Content Profile Worksheet
|===========================================
|
|* Institutions:
|UCB Bancroft Library
|University of the Pacific Library
|
|
|* Project name:
|John Muir letters digitization project
|
|
|* Context:
|Seeking LSTA funding to digitize microfilm reels of ca. 6,500
|letters they are primarily handwritten texts, 2-3 pages each),
|create imaged text objects with transcriptions in CONTENTdm,
|and make them accessible online via CONTENTdm (hosted
|by UoP) and Calisphere/OAC. OCLC will scan the letters and
|put them into CONTENTdm. UOP will do the transcriptions;
|UoP and UCB will create the metadata.
|
|
|* Funding:
|LSTA 2008-2009
|
|
|* Collection formats/genres:
|- Text documents (2-3 page letters)
|
|
|* Total number of objects:
|- ca. 6,500 objects
|
|
|* Finding aid?:
|Yes
|
|
|* Access plans:
|CONTENTdm (local website)
|OAC/Calisphere
|
|
|* Preservation plans:
|TBD
|
|
|* Timeline:
|July 2008-August 15, 2009
|
|
|* Digital object creation tool:
|CONTENTdm
|
|
|* Object types/content file formats:
|Compound imaged text objects:
|- JPEG2000 greyscale imaged text (access)
|- TIFF imaged text (master)
|- GIF/JPEG images (thumbnails)
|
|
|* Metadata types:
|- Dublin Core, both at compound object level and component
|levels
|- Transcriptions in metadata: the text and image are
|synchronized to
|the page, not the word. The transcriptions will be in the DC
|description field in the CONTENTdm export.
|
|EXAMPLES:
|http://digitalcollections.pacific.edu/cdm4/browse.php?
|CISOROOT=/locke
|
|
|* METS Profile:
|CONTENTdm profile - supported
|
|
|* CDL services sought:
|OAC/Calisphere
|
|
|* CDL parterning strategy suggested:
|- CDL will need to modify 7Train to handle component-level
|metadata in compound objects, and imaged text objects with
|associated text transcriptions
|- CDL will need to modify object viewers to support the
|above.
|
|
|* Contacts:
|Mary W. Elings
|Archivist for Digital Collections
|The Bancroft Library
|University of California
|Berkeley, CA 94720-6000
|melings*library.berkeley.edu
|Ph 510-643-2273
|Fx 510-643-2548
|
|Shan Sutton
|Head of Special Collections
|Holt-Atherton Special Collections
|University of the Pacific Library
|3601 Pacific Avenue
|Stockton CA 95211
|(209) 946-2945
|ssutton@pacific.edu
|
|
|===========================================
|A) CRITICAL PATH FOR LSTA 08-09
|===========================================
|
|
|1) OCLC will be creating metadata and content files
|(comprising A) imaged text files and B) full-text transcripts)
|for each page of a given letter. Each letter is approximately
|2-3 pages each. OCLC will then load the metadata and
|content files into CONTENTdm, and create one complex
|object per given letter.
|[DONE]
|
|2A) UoP will generate updated final initial batch of
|CONTENTdm Standard XML export, and relay to CDL. Will
|send other batches as they receive them.
|[DONE]
|
|2B) UCB DPG will optionally post TIFFs associated with
|CONTENTdm Standard XML export on their webserver, and
|supply CDL with URL to their location.
|[DONE]
|
|3A) CDL will derive METS with 7Train from the sample
|CONTENTdm Standard XML export, and assign CDL ARKs.
|We will relay METS to UoP/UCB TBL, along with an index that
|lists out the ARKs and titles for each object.
|[IN-PROCESS]
|
|3B) CDL will optionally harvest TIFFs, for creation of
|JPEG2000s.
|[IN-PROCESS]
|
|4) CDL will work up upgrading our object viewers to
|accommodate these new types of objects.
|
|Critical path:
|- Seek to model object view based on METS imaged text
|object. Example:
|http://content.cdlib.org/ark:/13030/hb2h4nb1ph/
|- Index full text
|- Show transcription for a given page as part of the
|metadata. Display it with a new label ("Transcription")?
|
|
|Ideal/preferred:
|- Seek to model object view based on METS TEI plus imaged
|text object -- include view toggles. Example:
|http://content.cdlib.org/ark:/13030/hb696nb2sg/
|- Index full text
|- For "Transcription" view: concatenate all transcriptions into
|one view -- visually separate each transcription with line
|breaks or hard rules?
|- For "View scanned version" view: show transcription for a
|given page as part of the metadata. Display it with a new
|label ("Transcription")?
|
|
|Longer term:
|- Reassess U/X and display of search results and object view
|(e.g., show keywords in context in search results, similar to
|METS TEIs)?
|
|
|5) CDL will finalize publication of the objects.
|
|6) UCB TBL will create a "temporary" finding aid for the METS,
|using GenDB -- the guide may include high-level links
|to associated objects; UCB TBL will upload the EAD into OAC.
|
|* LSTA grant objectives have been met at this point
|
|
|
|===========================================
|B) OUTSIDE OF SCOPE AND IMMEDIATE TIMELINE OF LSTA
|08-09
|===========================================
|
|10) UCB DPG will generate sample METS from GenDB
|(derived from the 7Train METS), comprising imaged text and
|full text transcriptions synchronized at the page level, and
|relay to CDL.
|
|11) CDL will work on upgrading our object viewers to
|accommodate these new types of objects.
|
|12) UCB DPG will load the 7Train'ed METS into GenDB.
|
|13) UCB DPG will generate updated METS and relay to CDL.
|
|14) CDL will ingest the updated METS into our access
|repository, for display in OAC/Calisphere.
|
|15) UCB DPG will optionally relay METS to CDL for
|preservation.
|
|16) UCB TBL will link the METS with the EAD finding aid, using
|GenDB; UCB TBL will upload the revised EAD into OAC. 
|Attachments: LSTAprojectsummary.doc bancroft_support_v2.doc cdl_in-kind_muir_project.xls CDLfundingIdeas.doc UOPLSTA6FinalDraft.doc UOPLSTAOCLCquote.pdf MetadataFieldsforJohnMuirCorrespondenceProject.doc Metadata_Muir(2).xls StandardDublinCoreExport.xml ContentDMStandardExport.txt mets.zip Muirletterwithcarriagereturns.xml 2008-09LSTAGrantExtensionLetter(3).pdf mets1.zip contentdm_example.xml muir_report.utf8 muir_report1.utf8 
+-----

Modified "transform_muir_contentdm.pl" to make the requested modification to
the data.  Then ran:

cd /voro/data/oac-lsta/non-lhdrp/bin
./transform_muir_contentdm.pl ../contentdm/cdm_ucb-uop.xml ../contentdm/transformed_cdm_ucb-uop.xml
./preprocess.pl ../contentdm/transformed_cdm_ucb-uop.xml ../contentdm/preprocessed_cdm_ucb-uop.xml cstoc_kt0w1031nc_
./run_7train.pl ../contentdm/preprocessed_cdm_ucb-uop.xml
./postprocess_muir_mets.pl

Committed the new METS to the CVS repository, and ingested them into production.
