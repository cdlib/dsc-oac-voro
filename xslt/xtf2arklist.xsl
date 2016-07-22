<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
>

  <xsl:output
    method="text"
    indent="yes"
  />

  <xsl:template match="/">
    <collection>
      <xsl:apply-templates
        select="(crossQueryResult//docHit)[1]/meta/relation-from"/>
      <xsl:apply-templates
        select="crossQueryResult//docHit/meta"/>
    </collection>
  </xsl:template>

  <xsl:template match="meta">
      <xsl:apply-templates select="identifier"/><xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="identifier">
           <xsl:value-of select="."/>
    <xsl:text>	</xsl:text>
  </xsl:template>

  <!-- identity template -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
