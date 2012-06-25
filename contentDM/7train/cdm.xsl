<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 	General:
 	The 7train transformation process is designed to produce METS objects
		from standardized XML files.  
 		This scenario was composed by Paul Fogel and Erik Hetzner at
		the California Digital Library (CDL) and 
 		is copyright the University of California Regents.
 		
 	Requirements:
 	7train requires the use of Saxon 8, as it is composed using XSL
		version 2.0.  It also requires that 2 working directories be
		created.  These directories are used for holding the data that 
 		a.) will be transformed and b.) saved as the result of the
		transformation.  These need to be named: "input" and "output"
		and need to be created at the same level as this stylesheet.
		The "input" directory contains both exports to be transformed
		as well as map files used to associate data not included in
		the export.  The resulting METS output from the transformation
		will be saved in "output".
 		See InstallAndRun.txt for more information.
 	
 	Customization:
 	7train.xsl is the base stylesheet in the transformation and defines
		the basic elements and structure of a METS file.  Local
		installations can customize this process by creating a
		stylesheet that imports 7train.xsl and overrides certain
		templates.  This stylesheet (cdm.xsl) is an example of a
		local installation designed to transform a specific XML
		file (CONTENTdm export) into a specific kind of METS.  
 		See Customizing.txt for more information and for specific
		examples.
-->
<xsl:transform version="2.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:seventrain="http://cdlib.org/7train/"
	xmlns:local="http://example.org/local/"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="#all"
	xmlns:idmap="java:org.cdlib.dsc.util.LHDRPassoc"
	extension-element-prefixes="idmap"
	>

	<!-- Import main stylesheet -->
	<xsl:import href="7train.xsl"/>
	<!-- Declare output type -->
	<xsl:output name="output1" method="xml" indent="yes" encoding="utf-8"/>

	<xsl:strip-space elements="*"/>

	<!-- Import mapping files into variables -->
	<!-- Check for  existence of files first -->
	<xsl:variable name="institutionmap">
		<xsl:choose>
			<xsl:when test="doc-available('institutions.xml')">
				<xsl:copy-of select="document('institutions.xml')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>empty</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
<!--
	<xsl:variable name="idmap">
		<xsl:choose>
			<xsl:when test="doc-available('../admin/idmap.xml')">
				<xsl:copy-of select="document('../admin/idmap.xml')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>empty</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
-->

	<!-- Calculate the ARK for the finding aid this object belongs to from the record/isPartof element -->
<!--
	<xsl:function name="local:eadark" as="xs:string">
		<xsl:param name="record" as="node( )"/>
		<xsl:choose>
			<xsl:when test="matches($record/isPartOf[1], '^.+/([a-z0-9]+)\s*$')">
				<xsl:value-of select="replace($record/isPartOf[1], '^.+/([a-z0-9]+)\s*$','$1')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">isPartOf[1] ("<xsl:value-of select="$record/isPartOf[1]"/>") does not match pattern.</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
-->
	<!-- the ARK for this finding aid is is in the added
		"<institutionFinderForCDL>" element -->
	<xsl:function name="local:eadark" as="xs:string">
		<xsl:param name="record" as="node( )"/>
		<xsl:choose>
			<xsl:when test="exists('$record/institutionFinderForCDL')">
				<xsl:value-of select="$record/institutionFinderForCDL"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">institutionFinderForCDL element is missing</xsl:message>
                        </xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Extract the Label/Title of the finding aid this object belongs to from the institution map-->
	<xsl:function name="local:eadlabel" as="xs:string">
		<xsl:param name="eadark" as="xs:string"/>
		<xsl:value-of select="$institutionmap/institutions/institution[@eadark=$eadark]/@eadlabel"/>
	</xsl:function>

	<!-- Extract the ARK for the owning/holding institution from the institution map -->
	<xsl:function name="local:instark" as="xs:string">
		<xsl:param name="eadark" as="xs:string"/>
		<xsl:value-of select="$institutionmap/institutions/institution[@eadark=$eadark]/@ark"/>
	</xsl:function>

	<!-- Extract the URL for the owning/holding institution's web page from the institution map-->
	<xsl:function name="local:url" as="xs:string">
		<xsl:param name="eadark" as="xs:string"/>
		<xsl:value-of select="$institutionmap/institutions/institution[@eadark=$eadark]/@url"/>
	</xsl:function>

	<!-- Extract the MARC code for the institution from the institution map -->
	<xsl:function name="local:marccode" as="xs:string">
		<xsl:param name="eadark" as="xs:string"/>
		<xsl:value-of select="$institutionmap/institutions/institution[@eadark=$eadark]/@marccode"/>
	</xsl:function>

	<!-- Extract the ARK from the id map -->
	<xsl:function name="local:arkfull" as="xs:string">
		<xsl:param name="record" as="node()"/>
<!--
		<xsl:value-of select="$idmap/objects/obj[@localid=$record/identifier[1]]/@uniqueid"/>
-->
<!--
		<xsl:value-of select="idmap:getAssoc($record/identifier[1])"/>
-->
		<xsl:choose>
			<xsl:when test="exists('$record/globallyUniqueIdentifierForCDL')">
				<xsl:value-of select="idmap:getAssoc($record/globallyUniqueIdentifierForCDL)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">globallyUniqueIdentifierForCDL element is missing</xsl:message>
                        </xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Calculate the ARK "stub" from the full ARK -->
	<xsl:function name="local:arkstub" as="xs:string">
		<xsl:param name="record" as="node()"/>
<!--
		<xsl:value-of
			select="replace($idmap/objects/obj[@localid=$record/identifier[1]]/@uniqueid,
			'^.+/([a-z0-9]+)$','$1')"
		/>
-->
<!--
		<xsl:value-of select="replace(idmap:getAssoc($record/identifier[1]),
			'^.+/([a-z0-9]+)$','$1')"/>
-->
		<xsl:choose>
			<xsl:when test="exists('$record/globallyUniqueIdentifierForCDL')">
				<xsl:value-of select="replace(idmap:getAssoc($record/globallyUniqueIdentifierForCDL), '^.+/([a-z0-9]+)$','$1')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">globallyUniqueIdentifierForCDL element is missing</xsl:message>
                        </xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Calculate the institution code from the identifier base -->
	<xsl:function name="local:instCode" as="xs:string">
		<xsl:param name="record" as="node()"/>
		<xsl:value-of select="lower-case(replace($record/identifier[1],'^([a-zA-Z]+)_.+$','$1'))"/>
	</xsl:function>

	<!-- Calculate the authoritative institution name from the institution map -->
	<xsl:function name="local:instName" as="xs:string">
		<xsl:param name="eadark" as="xs:string"/>
		<xsl:value-of select="$institutionmap/institutions/institution[@eadark=$eadark]/@name"/>
	</xsl:function>

	<!-- Controlled vocabulary map for the fileGrp@USE or file@USE attribute -->
	<xsl:variable name="cdmtype2usagetype">
		<local:metstype cdmtype="thumbnail">thumbnail image</local:metstype>
		<local:metstype cdmtype="master">archive image</local:metstype>
		<local:metstype cdmtype="access">reference image</local:metstype>
	</xsl:variable>

	<!-- Controlled vocabulary map for the file@MIMETYPE attribute -->
	<xsl:variable name="ext2mimetype">
		<local:mimetype ext="jpg">image/jpeg</local:mimetype>
		<local:mimetype ext="jpeg">image/jpeg</local:mimetype>
		<local:mimetype ext="gif">image/gif</local:mimetype>
		<local:mimetype ext="tif">image/tiff</local:mimetype>
		<local:mimetype ext="tiff">image/tiff</local:mimetype>
	</xsl:variable>

	<!-- Controlled vocabulary map for the mets@TYPE attribute -->
	<xsl:variable name="dcType2metsType">
		<local:metstype cdmtype="">image</local:metstype>
		<local:metstype cdmtype="image">image</local:metstype>
		<local:metstype cdmtype="text;">facsimile text</local:metstype>
		<local:metstype cdmtype="text">facsimile text</local:metstype>
		<local:metstype cdmtype="physicalobject">image</local:metstype>
		<local:metstype cdmtype="physical object">image</local:metstype>
	</xsl:variable>

	<xsl:variable name="base-element" select="QName('','record')"/>

	<!-- Record the local ID as the altRecordID, but only if there is a valid value in the idmap -->
	<xsl:template match="record" mode="seventrain:mets-metsHdr-altRecordID">
		<xsl:choose>
<!--
			<xsl:when test="normalize-space($idmap) eq 'empty'"/>
-->
			<xsl:when test="string-length(local:arkstub(.)) = 0"/>
			<xsl:otherwise>
				<mets:altRecordID>
					<xsl:value-of select="identifier[1]"/>
				</mets:altRecordID>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Use the Title of the object as the mets@LABEL attribute -->
	<xsl:template match="record" mode="seventrain:mets.LABEL">
		<xsl:value-of select="title"/>
	</xsl:template>

	<!-- Map the mets@TYPE attribute from the value in the export -->
	<xsl:template match="record" mode="seventrain:mets.TYPE">
		<xsl:variable name="dcType" select="lower-case(type[1])"/>
		<xsl:variable name="metsType" select="$dcType2metsType/local:metstype[@cdmtype=$dcType]"/>
		<xsl:choose>
			<xsl:when test="empty($metsType)">
				<xsl:text>image</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$metsType"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Populate the mets@OBJID attribute -->
	<xsl:template match="record" mode="seventrain:mets.OBJID">
		<xsl:choose>
			<!-- use the identifier from the export if there is no idmap -->
<!--
			<xsl:when test="normalize-space($idmap) eq 'empty'">
				<xsl:value-of select="identifier[1]"/>
			</xsl:when>
-->
			<!-- use the identifier from the export if there is no match in the idmap -->
			<xsl:when test="string-length(local:arkstub(.)) = 0">
				<xsl:value-of select="identifier[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="local:arkfull(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Define the output file name using the ARK stub -->
	<xsl:template match="record" mode="seventrain:output-filename">
		<!-- xsl:text>../output/</xsl:text -->
		<xsl:choose>
			<!-- use the identifier from the export if there is no idmap -->
<!--
			<xsl:when test="normalize-space($idmap) eq 'empty'">
				<xsl:value-of select="identifier[1]"/>
			</xsl:when>
-->
			<!-- use the identifier from the export if there is no match in the idmap -->
			<xsl:when test="string-length(local:arkstub(.)) = 0">
				<xsl:value-of select="identifier[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="local:arkstub(.)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>.mets.xml</xsl:text>
	</xsl:template>

	<xsl:template match="record" mode="seventrain:mets-metsHdr-agent">
		<mets:agent ROLE="EDITOR" TYPE="ORGANIZATION">
			<mets:name>California Digital Library</mets:name>
			<mets:note>Record created by conversion of CONTENTdm XML metadata</mets:note>
			<mets:note>Created using 7train</mets:note>
		</mets:agent>
	</xsl:template>

	<!-- Define METS profile -->
	<xsl:template match="record" mode="seventrain:mets.PROFILE">
		<!-- xsl:text>http://ark.cdlib.org/mets/profiles/7trainProfile.xml</xsl:text -->
		<xsl:text>http://www.loc.gov/mets/profiles/00000010.xml</xsl:text>
	</xsl:template>

	<!-- Build the primary dmdSec of the METS;
		  Call the crosswalker and process the record - this calls xwalker.xsl which contains the logic for 
			  processing the mappings, with the specific mappings defined in the $xwalk-file parameter -->
	<xsl:template match="record" mode="seventrain:mets-dmdSec">
		<mets:dmdSec ID="DC" CREATED="{current-dateTime()}">
			<mets:mdWrap MIMETYPE="text/xml" MDTYPE="DC" LABEL="DC">
				<mets:xmlData>
					<xsl:call-template name="seventrain:xwalker">
						<xsl:with-param name="input" select="."/>
						<xsl:with-param name="xwalk-file" select="'cdmmd2dc.xwalk'"/>
					</xsl:call-template>
				</mets:xmlData>
			</mets:mdWrap>
		</mets:dmdSec>
		<xsl:call-template name="local:dmdSec"/>
	</xsl:template>

	<!-- Build the EAD and Repository dmdSecs -->
	<xsl:template name="local:dmdSec">
		<xsl:variable name="eadark">
			<xsl:value-of select="local:eadark(.)"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space($institutionmap) eq 'empty'"/>
			<xsl:otherwise>
				<mets:dmdSec ID="ead">
					<mets:mdRef LOCTYPE="URL" MDTYPE="EAD">
						<xsl:attribute name="ID">
							<xsl:value-of select="$eadark"/>
						</xsl:attribute>
						<xsl:attribute name="LABEL">
							<xsl:value-of select="local:eadlabel($eadark)"/>
						</xsl:attribute>
						<xsl:attribute name="xlink:href">
							<xsl:text>http://www.oac.cdlib.org/findaid/ark:/13030/</xsl:text>
							<xsl:value-of select="$eadark"/>
						</xsl:attribute>
					</mets:mdRef>
				</mets:dmdSec>
				<mets:dmdSec ID="repo">
					<mets:mdWrap MIMETYPE="text/xml" MDTYPE="DC" LABEL="Repository">
						<mets:xmlData>
							<dc:title>
								<xsl:value-of select="local:instName($eadark)"/>
							</dc:title>
							<dc:identifier>
								<xsl:value-of select="local:instark($eadark)"/>
							</dc:identifier>
							<dc:identifier>
								<xsl:value-of select="local:url($eadark)"/>
							</dc:identifier>
						</mets:xmlData>
					</mets:mdWrap>
				</mets:dmdSec>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Build fileSec -->
	<xsl:template match="record" mode="seventrain:mets-fileSec">
		<mets:fileSec ID="FILESECID-{seventrain:gen-id(.)}">
			<xsl:apply-templates select="thumbnailURL" mode="seventrain:mets-fileSec"/>
			<xsl:apply-templates select="structure" mode="seventrain:mets-fileSec"/>
			<xsl:apply-templates select="fullResolution" mode="seventrain:mets-fileSec"/>
		</mets:fileSec>
	</xsl:template>

	<!-- Build thumbnail fileGrp for simple objects.
		Checks for thumbnail urls which do not have a complex <structure> sibling, i.e. <structure> that is a text node. -->
	<xsl:template match="thumbnailURL[../structure[text()]]" mode="seventrain:mets-fileSec">
		<mets:fileGrp USE="thumbnail image">
			<xsl:call-template name="local:file-from-url">
				<xsl:with-param name="url" select="."/>
				<xsl:with-param name="cdm-type" select="'thumbnail'"/>
				<!-- xsl:with-param name="title" select="../title"/ -->
			</xsl:call-template>
		</mets:fileGrp>
	</xsl:template>

	<!-- Suppress output of fileSec group for complex objects. -->
	<xsl:template match="thumbnailURL[not(../structure[text()])]" mode="seventrain:mets-fileSec"/>

	<!-- Build reference image fileGrp for simple objects -->
	<xsl:template match="structure[text()]" mode="seventrain:mets-fileSec">
		<mets:fileGrp USE="reference image">
			<xsl:call-template name="local:file-from-url">
				<xsl:with-param name="url" select="."/>
				<xsl:with-param name="cdm-type" select="'access'"/>
				<!-- xsl:with-param name="title" select="../title"/ -->
			</xsl:call-template>
		</mets:fileGrp>
	</xsl:template>

	<!-- Build archive image fileGrp for simple objects -->
	<xsl:template match="fullResolution[../structure[text()]]" mode="seventrain:mets-fileSec">
		<!-- xsl:if test="normalize-space(.) ne ''" -->
		<!-- ======================================================
			If statement removed so that large JPG on Ingest1 can be included -->
		<mets:fileGrp USE="archive image">
			<xsl:call-template name="local:file-from-url">
				<xsl:with-param name="url" select="if (. ne '') then . else concat('CDuk\',../identifier[1],'.tif') "/>
				<xsl:with-param name="cdm-type" select="'master'"/>
			</xsl:call-template>
		</mets:fileGrp>
		<!-- /xsl:if -->
	</xsl:template>

	<!-- Build the fileGrps for complex objects, using each pagefile -->
	<xsl:template match="structure" mode="seventrain:mets-fileSec">
		<xsl:param name="instCode"/>
		<xsl:for-each-group select=".//page/pagefile" group-by="pagefiletype">
			<mets:fileGrp>
				<xsl:attribute name="USE">
					<xsl:value-of select="$cdmtype2usagetype/local:metstype[@cdmtype=current-grouping-key()]"
					/>
				</xsl:attribute>
				<xsl:apply-templates select="current-group()" mode="seventrain:mets-fileSec"/>
				<!-- ==============  For extra link to Ingest1 for large JPG========================== 
				<mets:file ID="{generate-id()}" MIMETYPE="image/jpeg" GROUPID="{../pagetitle}">
					<mets:FLocat LOCTYPE="URL" xlink:role="master">
						<xsl:attribute name="xlink:href">
							<xsl:text>http://ingest1.cdlib.org/LSTA-2ndGen/</xsl:text>
							<xsl:value-of select="local:instCode(.)"/>
							<xsl:text>jpeg</xsl:text>
							<xsl:value-of select="identifier[1]"/>
							<xsl:text>.jpg</xsl:text>
						</xsl:attribute>
					</mets:FLocat>
				</mets:file>
				==============  For extra link to Ingest1 for large JPG========================== -->
			</mets:fileGrp>
		</xsl:for-each-group>
		<xsl:if test="normalize-space(string-join(.//page/pagetext, '')) ne ''">
			<mets:fileGrp USE="transcription">
				<xsl:apply-templates select=".//page/pagetext" mode="seventrain:mets-fileSec"/>
			</mets:fileGrp>
		</xsl:if>
	</xsl:template>

	<!-- Grab the text transcription and build an FContent wrapping the XML, if not empty -->
	<!-- 2009/7/2 5pm MAR
	The "generate-id( )" function uses the current node if the node set
	is omitted.  Somehow, the current node is the same for the first
	archive image as it is for the transcription.  To keep the same
	ID from being used twice, prefix the return value of "generate-id( )"
	for the transcription with "xscrptn".
	-->
	<xsl:template match="pagetext" mode="seventrain:mets-fileSec">
		<xsl:if test="normalize-space(string-join(., '')) ne ''">
			<mets:file ID="xscrptn{generate-id()}" MIMETYPE="text/xml" GROUPID="{../pagetitle}">
				<mets:FContent>
					<mets:xmlData>
						<transcription>
							<xsl:value-of select="normalize-space(.)"/>
						</transcription>
					</mets:xmlData>
				</mets:FContent>
			</mets:file>
		</xsl:if>
	</xsl:template>

	<!-- Set the parameters and call the template that creates the file and FLocat elements -->
	<xsl:template match="pagefile" mode="seventrain:mets-fileSec">
		<xsl:call-template name="local:file-from-url">
			<xsl:with-param name="url" select="
					if (pagefilelocation ne '') 
					then pagefilelocation 
					else concat('CDunk\',local:instCode(ancestor::record),'_',../pagetitle,'.tif')
			"/>
			<xsl:with-param name="cdm-type" select="pagefiletype"/>
			<xsl:with-param name="title" select="../pagetitle"/>
		</xsl:call-template>
	</xsl:template>

	<!-- Build the file and FLocat elements -->
	<xsl:template name="local:file-from-url">
		<xsl:param name="url"/>
		<xsl:param name="cdm-type"/>
		<xsl:param name="title"/>
		<xsl:variable name="file-ext" select="lower-case(replace($url, '^.+\.([a-zA-Z0-9]+)$','$1'))"/>
		<xsl:variable name="metstype" select="$cdmtype2usagetype/local:metstype[@cdmtype=$cdm-type]"/>
		<xsl:variable name="mimetype" select="$ext2mimetype/local:mimetype[@ext=$file-ext]"/>
		<xsl:choose>
			<!-- ===============================================
		            For extra link to Ingest1 for large JPG           -->
			<xsl:when test="normalize-space($cdm-type) eq 'master'">
				<mets:file ID="FILEID-{seventrain:gen-id(following-sibling::*[1])}" MIMETYPE="image/jpeg">
                    <!--<mets:file ID="{generate-id(following-sibling::*[1])}" MIMETYPE="image/jpeg">-->
					<xsl:if test="$title ne ''">
						<xsl:attribute name="GROUPID">
							<xsl:value-of select="$title"/>
						</xsl:attribute>
					</xsl:if>
					<mets:FLocat LOCTYPE="URL" xlink:role="access">
						<xsl:attribute name="xlink:href">
							<xsl:text>http://ingest1.cdlib.org/LSTA-2ndGen/</xsl:text>
							<!-- xsl:value-of select="local:instCode(parent::node())"/ -->
							<xsl:value-of select="local:instCode(ancestor::record)"/>
							<xsl:text>/jpeg/</xsl:text>
							<xsl:choose>
							  <!-- Does the URL contain a backslash and end in tif/jpg?  -->
							  <xsl:when test="matches(lower-case($url), '\\[^\\]+\.(tif|jpg)$')">
							    <!-- Yes.  Pull out whatever is between the rightmost backslash
							    and the file name extension.  -->
							    <xsl:analyze-string select="lower-case($url)" regex="\\([^\\]+)\.(tif|jpg)$">
							      <xsl:matching-substring>
								<xsl:value-of select="regex-group(1)"/>
							      </xsl:matching-substring>
							    </xsl:analyze-string>
							  </xsl:when>
							  <!-- No backslash.  Does the URL end in tif/jpg?  -->
							  <xsl:when test="matches(lower-case($url), '^.+\.(tif|jpg)$')">
							    <!-- Yes.  Pull out whatever not the file name extension.  -->
							    <xsl:analyze-string select="lower-case($url)" regex="^(.+)\.(tif|jpg)$">
							      <xsl:matching-substring>
								<xsl:value-of select="regex-group(1)"/>
							      </xsl:matching-substring>
							    </xsl:analyze-string>
							  </xsl:when>
							  <xsl:otherwise>
							    <xsl:message terminate="yes">File name extension was neither ".tif" nor ".jpg" in "<xsl:value-of select="$url"/>".</xsl:message>
							  </xsl:otherwise>
							</xsl:choose>
							<xsl:text>.jpg</xsl:text>
						</xsl:attribute>
					</mets:FLocat>
				</mets:file>
				<!-- ================================================== -->
				<!-- Do not build file & FLocat if there is no URL content -->
				<xsl:if test="normalize-space($url) ne ''">
					<mets:file ID="FILEID-{seventrain:gen-id(.)}">
                        <!--<mets:file ID="{generate-id()}">-->
						<xsl:if test="normalize-space($title) ne ''">
							<xsl:attribute name="GROUPID">
								<xsl:value-of select="$title"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="$mimetype ne ''">
							<xsl:attribute name="MIMETYPE">
								<xsl:value-of select="$mimetype"/>
							</xsl:attribute>
						</xsl:if>
						<mets:FLocat LOCTYPE="URL">
							<xsl:attribute name="xlink:href">
								<xsl:text>http://ingest1.cdlib.org/LSTA-2ndGen/</xsl:text>
								<xsl:value-of select="local:instCode(ancestor::record)"/>
								<xsl:text>/tiff/</xsl:text>

								<xsl:choose>
								  <!-- Does the URL contain a backslash and end in tif/jpg?  -->
								  <xsl:when test="matches(lower-case($url), '\\[^\\]+\.(tif|jpg)$')">
								    <!-- Yes.  Pull out whatever is between the rightmost backslash
								    and the file name extension.  -->
								    <xsl:analyze-string select="lower-case($url)" regex="\\([^\\]+\.(tif|jpg))$">
								      <xsl:matching-substring>
									<xsl:value-of select="regex-group(1)"/>
								      </xsl:matching-substring>
								    </xsl:analyze-string>
								  </xsl:when>
								  <!-- No backslash.  Does the URL end in tif/jpg?  -->
								  <xsl:when test="matches(lower-case($url), '^.+\.(tif|jpg)$')">
								    <!-- Yes.  Pull out whatever not the file name extension.  -->
								    <xsl:analyze-string select="lower-case($url)" regex="^(.+\.(tif|jpg))$">
								      <xsl:matching-substring>
									<xsl:value-of select="regex-group(1)"/>
								      </xsl:matching-substring>
								    </xsl:analyze-string>
								  </xsl:when>
								  <xsl:otherwise>
								    <xsl:message terminate="yes">File name extension was neither ".tif" nor ".jpg" in "<xsl:value-of select="$url"/>".</xsl:message>
								  </xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:attribute name="xlink:role">
								<xsl:value-of select="$cdm-type"/>
							</xsl:attribute>
						</mets:FLocat>
					</mets:file>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- Do not build file & FLocat if there is no URL content -->
				<xsl:if test="normalize-space($url) ne ''">
					<mets:file ID="FILEID-{seventrain:gen-id(.)}">
                        <!--<mets:file ID="{generate-id()}">-->
						<xsl:if test="normalize-space($title) ne ''">
							<xsl:attribute name="GROUPID">
								<xsl:value-of select="$title"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="$mimetype ne ''">
							<xsl:attribute name="MIMETYPE">
								<xsl:value-of select="$mimetype"/>
							</xsl:attribute>
						</xsl:if>
						<mets:FLocat LOCTYPE="URL">
							<xsl:attribute name="xlink:href">
								<xsl:value-of select="$url"/>
							</xsl:attribute>
							<xsl:attribute name="xlink:role">
								<xsl:value-of select="$cdm-type"/>
							</xsl:attribute>
						</mets:FLocat>
					</mets:file>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Build the structMap and top-level div for all objects (simple and complex)-->
	<xsl:template match="record" mode="seventrain:mets-structMap">
		<mets:structMap>
			<mets:div ID="DIVID-{seventrain:gen-id(.)}" DMDID="DC">
				<xsl:attribute name="LABEL">
					<xsl:value-of select="title"/>
				</xsl:attribute>
				<xsl:apply-templates select="structure" mode="seventrain:mets-structMap"/>
			</mets:div>
		</mets:structMap>
	</xsl:template>

	<!-- *For simple objects only* (matching a text node for structure):
			call templates to build thumbnail and master image divs and 
			build reference/access image div-->
	<xsl:template match="structure[text()]" mode="seventrain:mets-structMap">
		<xsl:apply-templates select="../thumbnailURL" mode="seventrain:mets-structMap"/>
		<mets:div ID="DIVID-{seventrain:gen-id(.)}" TYPE="reference image">
            <!--<mets:fptr ID="{seventrain:gen-id(.)}" FILEID="{generate-id()}"/>-->
			<mets:fptr ID="FPTRID-{seventrain:gen-id(.)}" FILEID="FILEID-{seventrain:gen-id(.)}"/>
		</mets:div>
		<xsl:apply-templates select="../fullResolution" mode="seventrain:mets-structMap"/>
	</xsl:template>

	<!-- Build the thumbnail div and fptr for simple objects -->
	<xsl:template match="thumbnailURL" mode="seventrain:mets-structMap">
		<mets:div ID="DIVID-{seventrain:gen-id(.)}" TYPE="thumbnail image">
			<mets:fptr ID="FPTRID-{seventrain:gen-id(.)}" FILEID="FILEID-{seventrain:gen-id(.)}"/>
		</mets:div>
	</xsl:template>

	<!-- Build the master image div and fptr for simple objects; omit if there is no URL content -->
	<xsl:template match="fullResolution" mode="seventrain:mets-structMap">
		<!-- ===================================================
			For adding extra link to Ingest1 JPG -->
		<mets:div ID="DIVID-{seventrain:gen-id(.)}" TYPE="archive image">
            <!--<mets:fptr ID="{seventrain:gen-id(.)}" FILEID="{generate-id(following-sibling::*[1])}"/>-->
			<mets:fptr ID="FPTRID-{seventrain:gen-id(.)}" FILEID="FILEID-{seventrain:gen-id(following-sibling::*[1])}"/>
		</mets:div>
		<!-- =================================================== -->
		<xsl:if test="normalize-space(.) ne ''">
			<mets:div ID="DIVID-{seventrain:gen-id(.)}" TYPE="archive image">
			    <mets:fptr ID="FPTRID-{seventrain:gen-id(.)}" FILEID="FILEID-{seventrain:gen-id(.)}"/>
			</mets:div>
		</xsl:if>
	</xsl:template>

	<!-- *For complex objects only* (matching an element node for structure):
			Determine the type (degree of complexity) of complex object -->
	<xsl:template match="structure" mode="seventrain:mets-structMap">
		<xsl:choose>
			<xsl:when test="exists(node/page)">
				<xsl:apply-templates select="node" mode="seventrain:mets-structMap"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="page" mode="seventrain:mets-structMap"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Build mid-level div structure for complex objects; skip node elements that have no page element children -->
	<xsl:template match="node" mode="seventrain:mets-structMap">
		<xsl:variable name="nodecount" select="count(../node[page])"/>
		<xsl:choose>
			<xsl:when test="$nodecount = 1">
				<xsl:apply-templates select="page" mode="seventrain:mets-structMap"/>
			</xsl:when>
			<xsl:otherwise>
				<mets:div ID="DIVID-{seventrain:gen-id(.)}">
					<xsl:attribute name="LABEL">
						<xsl:value-of select="nodetitle"/>
					</xsl:attribute>
					<xsl:apply-templates select="page" mode="seventrain:mets-structMap"/>
				</mets:div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Build lower-level div for complex objects; call template to build lowest-level div and fptr -->
	<xsl:template match="page" mode="seventrain:mets-structMap">
		<mets:div ID="DIVID-{seventrain:gen-id(.)}" LABEL="{pagetitle}">
			<xsl:apply-templates select="pagefile|pagetext" mode="seventrain:mets-structMap"/>
		</mets:div>
	</xsl:template>
	
	<!-- Build lowest-level div and fptr for complex objects; determine div@TYPE; 
			repress building of div if URL is missing-->
	<xsl:template match="pagefile" mode="seventrain:mets-structMap">
		<xsl:if test="pagefilelocation">
			<xsl:variable name="pagefiletype" select="pagefiletype"/>
			<xsl:variable name="label" select="$cdmtype2usagetype/local:metstype[@cdmtype=$pagefiletype]"/>
			<!-- xsl:variable name="type">
				<xsl:choose>
					<xsl:when test="$label='thumbnail image'">thumbnail image</xsl:when>
					<xsl:when test="$label='reference image'">reference image</xsl:when>
					<xsl:when test="$label='archive image'">hidden</xsl:when>
				</xsl:choose>
				</xsl:variable -->
			<xsl:choose>
				<!-- ===================================================
				           for adding extra link to Ingest1 for large JPG   -->
				<xsl:when test="$label eq 'archive image'">
					<mets:div ID="DIVID-{seventrain:gen-id(.)}" TYPE="{$label}">
						<mets:fptr FILEID="FILEID-{seventrain:gen-id(following-sibling::*[1])}"/>
					</mets:div>
					<mets:div ID="DIVID-{seventrain:gen-id(.)}" TYPE="{$label}">
						<mets:fptr FILEID="FILEID-{seventrain:gen-id(.)}"/>
					</mets:div>
				<!--  ================================================= -->
				</xsl:when>
				<xsl:otherwise>
					<mets:div ID="DIVID-{seventrain:gen-id(.)}" TYPE="{$label}">
						<mets:fptr FILEID="FILEID-{seventrain:gen-id(.)}"/>
					</mets:div>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Build div and fptr for text transcriptions -->
	<xsl:template match="pagetext[normalize-space(.) ne '']" mode="seventrain:mets-structMap">
		<mets:div ID="DIVID-{seventrain:gen-id(.)}" TYPE="transcription">
						<mets:fptr FILEID="FILEID-{seventrain:gen-id(.)}"/>
			<mets:fptr FILEID="xscrptn{generate-id()}"/>
		</mets:div>
	</xsl:template>

	<!-- Build amdSec -->
	<xsl:template match="record" mode="seventrain:mets-amdSec"/>

</xsl:transform>
