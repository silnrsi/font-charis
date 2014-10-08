<?xml version="1.0"?>

<!-- normalize glypph supplemental info
     sort glyphs 
     used to process output of FLGlyphSuppXml.py and SetPSNms.py -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- xsl:output method="xml" indent="yes" omit-xml-declaration="no" doctype-system="gsi.dtd"/ -->
<xsl:output method="xml" indent="yes" omit-xml-declaration="no" />

<!-- *** sort glyphs *** -->
<xsl:template match="font">
<xsl:text disable-output-escaping="yes">
&lt;!DOCTYPE font SYSTEM "gsi.dtd"&gt;
</xsl:text>
  <xsl:copy >
  <xsl:apply-templates select="glyph" mode="gsi">
  	<!-- sort by sort attrib -->
    <xsl:sort select="number(./@sort)" data-type="number"/> 
    
    <!-- sort by feature cat & value & glyph name -->
    <!-- 
    <xsl:sort select="./feature" data-type="text"/> 
    <xsl:sort select="./feature/@category" data-type="text"/> 
    <xsl:sort select="./feature/@value" data-type="text"/> 
    -->
    
    <!-- sort by SIL Nm -->
    <xsl:sort select="./@name" data-type="text"/> 
  </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="glyphs">
<xsl:text disable-output-escaping="yes">
&lt;!DOCTYPE glyphs SYSTEM "mgi.dtd"&gt;
</xsl:text>
  <xsl:copy >
  <xsl:apply-templates select="glyph" mode="mgi">
  	<!-- sort by sort attrib -->
    <xsl:sort select="number(./@sort)" data-type="number"/>
    
    <!-- sort by feature cat & value & glyph name -->
    <!-- 
    <xsl:sort select="./feature" data-type="text"/> 
    <xsl:sort select="./feature/@category" data-type="text"/> 
    <xsl:sort select="./feature/@value" data-type="text"/> 
    -->
    
    <!-- sort by SIL Nm -->
    <xsl:sort select="./@name" data-type="text"/>
  </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="glyph" mode="gsi">
  <glyph active="{@active}" contour="{@contour}" sort="{@sort}" name="{@name}">
  <xsl:if test="./comment">
    <comment><xsl:value-of select="./comment"/></comment>
  </xsl:if>
  <ps_name value="{./ps_name/@value}"/>
  <xsl:if test="./var_uid">
    <var_uid><xsl:value-of select="./var_uid"/></var_uid>
  </xsl:if>
  <xsl:if test="./lig_uids">
    <lig_uids><xsl:value-of select="./lig_uids"/></lig_uids>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="./feature/@value">
      <feature category="{./feature/@category}" value="{./feature/@value}"/>
    </xsl:when>
    <xsl:when test="./feature/@category">
      <feature category="{./feature/@category}"/>
    </xsl:when>
  </xsl:choose>
  <xsl:if test="./composite">
    <composite draft="{./composite/@draft}">
      <xsl:if test="./composite/comment">
        <comment><xsl:value-of select="./composite/comment"/></comment>
      </xsl:if>
      <xsl:apply-templates select="./composite/glyph" mode="composite"/>
      <xsl:apply-templates select="./composite/comp_glyph"/> <!-- handle already normalized output -->
    </composite>
  </xsl:if>
  </glyph>
</xsl:template> 

<xsl:template match="glyph" mode="mgi">
  <glyph>
  <xsl:attribute name="family"><xsl:value-of select="./@family"/></xsl:attribute>
  <xsl:if test="./@inactive='1'">
    <xsl:attribute name="inactive"><xsl:value-of select="./@inactive"/></xsl:attribute>
  </xsl:if>
  <xsl:if test="./@contourTT">
    <xsl:attribute name="contourTT"><xsl:value-of select="./@contourTT"/></xsl:attribute>
  </xsl:if>
  <xsl:attribute name="sort"><xsl:value-of select="./@sort"/></xsl:attribute>
  <xsl:attribute name="name"><xsl:value-of select="./@name"/></xsl:attribute>
  <xsl:if test="./comment">
    <comment><xsl:value-of select="./comment"/></comment>
  </xsl:if>
  <ps_name value="{./ps_name/@value}"/>
  <xsl:if test="./var_uid">
    <var_uid><xsl:value-of select="./var_uid"/></var_uid>
  </xsl:if>
  <xsl:if test="./lig_uids">
    <lig_uids><xsl:value-of select="./lig_uids"/></lig_uids>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="./feature/@value">
      <feature category="{./feature/@category}" value="{./feature/@value}"/>
    </xsl:when>
    <xsl:when test="./feature/@category">
      <feature category="{./feature/@category}"/>
    </xsl:when>
  </xsl:choose>
  <xsl:if test="./composite">
    <composite>
      <xsl:if test="./composite/@draft">
        <xsl:attribute name="draft"><xsl:value-of select="./composite/@draft"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="./composite/comment">
        <comment><xsl:value-of select="./composite/comment"/></comment>
      </xsl:if>
      <xsl:apply-templates select="./composite/glyph" mode="composite"/>
      <xsl:apply-templates select="./composite/comp_glyph"/> <!-- handle already normalized output -->
    </composite>
  </xsl:if>
  </glyph>
</xsl:template> 

<!-- push mode templates for composite/glpyh element since structure is not fixed -->

<xsl:template match="glyph" mode="composite">
  <comp_glyph PSName="{@PSName}"> <!-- change the glyph element name -->
    <xsl:if test="@UID">
      <xsl:attribute name="UID">
        <xsl:value-of select="@UID"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </comp_glyph>
</xsl:template>

<xsl:template match="comp_glyph">
  <comp_glyph PSName="{@PSName}">
    <xsl:if test="@UID">
      <xsl:attribute name="UID">
        <xsl:value-of select="@UID"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </comp_glyph>
</xsl:template>

<xsl:template match="base">
  <base PSName="{@PSName}">
    <xsl:apply-templates/>
  </base>
</xsl:template>

<xsl:template match="attach">
  <attach PSName="{@PSName}">
    <xsl:if test="@with">
      <xsl:attribute name="with">
        <xsl:value-of select="@with"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@at">
      <xsl:attribute name="at">
        <xsl:value-of select="@at"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </attach>
</xsl:template>

<xsl:template match="shift">
  <shift>  
    <xsl:if test="@x">
      <xsl:attribute name="x">
        <xsl:value-of select="@x"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@y">
      <xsl:attribute name="y">
        <xsl:value-of select="@y"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </shift>
</xsl:template>

<!-- xsl:template match="comment()">
  <xsl:copy-of select="."/>
</xsl:template -->

<!-- remove excess eols so inputting normalized XML will produce an identical output file -->
<xsl:template match="text()">
  <xsl:value-of select="normalize-space(.)"/> 
</xsl:template>


<!-- was used to copy glyph sub-tree inside composite -->
<!-- xsl:template match="node()|@*" mode="identity" -->
<xsl:template match="node()" mode="identity">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="identity"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
