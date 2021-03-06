<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- http://www.tei-c.org/wiki/index.php/Remove-Namespaces.xsl -->
<xsl:output method="xml" indent="no" doctype-system="http://oac.cdlib.org/ents/ead.dtd"/>

<xsl:template match="/|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<xsl:template match="*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
</xsl:template>

<xsl:template match="@*">
 <xsl:choose>
  <xsl:when test="local-name() = 'schemaLocation'"/>
  <xsl:when test="local-name() = 'actuate'">
    <xsl:attribute name="actuate">
	<xsl:choose>
	  <xsl:when test=".  = 'onRequest' ">
		<xsl:text>onrequest</xsl:text>
	  </xsl:when>
	  <xsl:when test=".  = 'onLoad' ">
		<xsl:text>onload</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
      <xsl:value-of select="."/>
	  </xsl:otherwise>
	</xsl:choose>
    </xsl:attribute>
  </xsl:when>
  <xsl:otherwise>
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>
</xsl:stylesheet>
