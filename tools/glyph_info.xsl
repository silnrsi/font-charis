<?xml version="1.0"?> 

<!-- generate a list of SIL Names, sort numbers, and PS Names
	from the glyph supplement XML -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes"/>

<xsl:template match="font">
  <xsl:for-each select="./glyph[@active = '1']">
    <xsl:sort select="@sort" data-type="number" />
    <xsl:value-of select="@name" disable-output-escaping="yes" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="@sort" disable-output-escaping="yes" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="ps_name/@value" disable-output-escaping="yes" />
    <xsl:text> </xsl:text>
    <xsl:text><!-- output line break, will be Unix style -->
</xsl:text>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
