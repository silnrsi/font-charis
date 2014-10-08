<?xml version="1.0"?>

<!-- Extract Glyph Supplemental Info for specific fonts from the Master Glyph Info file.
     The Font to extract can be specified on the command line, eg "Font-Spec=GR".
     The default font to extract is Doulos Reg.
      -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- set DTD below instead of using doctype-system parameter -->
<!-- xsl:output method="xml" indent="yes" omit-xml-declaration="no" doctype-system="gsi.dtd"/ -->
<xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>

<!-- xsl:variable name="Family-Spec">G</xsl:variable>
<xsl:variable name="Font-Spec">GR</xsl:variable !-->

<!-- pass parameter values on command line with param=value
     eg "Font-Spec=GR" on Windows command line. quotes are needed -->
<xsl:param name="Font-Spec">DR</xsl:param> <!-- DR is the default -->
<!-- xsl:param name="Family-Spec">D</xsl:param --> <!-- D is the default -->
<xsl:variable name="Family-Spec" select="substring($Font-Spec,1,1)"/>

<!-- *** select glyphs *** -->
<xsl:template match="glyphs">
<!-- output DTD first -->
<xsl:text disable-output-escaping="yes">
&lt;!DOCTYPE font SYSTEM "gsi.dtd"&gt;
</xsl:text>
  <font>
  <xsl:apply-templates select="glyph[contains(@family, $Family-Spec)]" />
  </font>
</xsl:template>

<!-- glyph element - converting to active and contour attributes -->
<xsl:template match="glyph">
  <xsl:copy>
    <xsl:choose>
    <xsl:when test="@inactive=1">
      <xsl:attribute name="active">0</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>  <!-- @inactive defaults to 0 in DTD if @inactive not present -->
      <xsl:attribute name="active">1</xsl:attribute>
    </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
    <xsl:when test="contains(@contourTT, $Font-Spec)">
      <xsl:attribute name="contour">TT</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="contour">T1</xsl:attribute> <!-- also used if no contourTT attrib exists -->
    </xsl:otherwise>
    </xsl:choose>
  <xsl:attribute name="sort"><xsl:value-of select="@sort"/></xsl:attribute>
  <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
  <xsl:apply-templates />
  </xsl:copy>
</xsl:template>
 
<!-- keeps multi-line comments as multi-line -->
<xsl:template match="comment">
  <comment><xsl:value-of select="."/></comment>
</xsl:template>

<!-- composite element - converting the draft attribute -->
<xsl:template match="composite">
  <xsl:copy>
    <xsl:choose>
    <xsl:when test="contains(@draft, $Font-Spec)">
      <xsl:attribute name="draft">true</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="draft">false</xsl:attribute> <!-- also used if no draft attrib exists -->
    </xsl:otherwise>
    </xsl:choose>
  <xsl:apply-templates />
  </xsl:copy>
</xsl:template>

<xsl:template match="*"> <!-- copy any element not matched above thru to the output -->
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates />
  </xsl:copy>
</xsl:template>

<xsl:template match="text()"> <!-- normalize text content of elements -->
   <xsl:value-of select="normalize-space(.)" />
</xsl:template>

</xsl:stylesheet>
