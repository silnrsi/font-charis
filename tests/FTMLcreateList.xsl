<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="utf-8"/>

<!-- http://github.com/silnrsi/pysilfont -->
<!-- Copyright (c) 2015 SIL International (http://www.sil.org) -->
<!-- Released under the MIT License (http://opensource.org/licenses/MIT) -->

<!-- set variables from head element -->
<xsl:variable name="width-comment" select="/ftml/head/widths/@comment"/>
<xsl:variable name="width-label" select="/ftml/head/widths/@label"/>
<xsl:variable name="width-string" select="/ftml/head/widths/@string"/>
<xsl:variable name="width-stylename" select="/ftml/head/widths/@stylename"/>
<xsl:variable name="width-table" select="/ftml/head/widths/@table"/>
<xsl:variable name="font-scale" select="concat(/ftml/head/fontscale, substring('100', 1 div not(/ftml/head/fontscale)))"/>

<!-- hard-coded processing options: -->

<!-- if $useCSSstyles is non-empty then emit and use CSS styles for font feature settings;
     otherwise font feature settings are output with the test strings  -->
<xsl:variable name="useCSSstyles"></xsl:variable>	

<!-- 
	Process the root node to construct the html page
-->
<xsl:template match="/">
<html>
	<head>
        <script>
            function regtochar(match, p1) {
                p1 = parseInt(p1,16);
                if (p1 > 0xFFFF) {    // must generate UTF-16
                    p1 -= 0x10000;
                    return String.fromCharCode(0xD800 + (p1 >> 10), 0xDC00 + (p1 &amp; 0x3FF));
                } else {
                    return String.fromCharCode(p1);
                }
            };
            function init() {
                var tw = document.createTreeWalker(document.body , NodeFilter.SHOW_TEXT, null, false);
                while (tw.nextNode()) {
                    tw.currentNode.textContent = tw.currentNode.textContent.replace(/\\u([0-9A-F]{4,6})/gi, regtochar);
                };
            };
        </script>
		<title>
			<xsl:value-of select="ftml/head/title"/>
		</title>
		<meta name="description">
			<xsl:attribute name="content">
				<xsl:value-of select="ftml/head/comment"/>
			</xsl:attribute>
		</meta>
		<style>
	body, td { font-family: sans-serif; }
	@font-face {font-family: TestFont; src: <xsl:value-of select="ftml/head/fontsrc"/>; }
	th { text-align: left; }
	table,th,td { padding: 2px; border: 1px solid #111111; border-collapse: collapse; }
	.string {font-family: TestFont; font-size: <xsl:value-of select="$font-scale"/>%; }
<xsl:if test="$width-table != ''">
	table { width: <xsl:value-of select="$width-table"/>; }
</xsl:if>
<xsl:if test="$width-label != ''">
	.label { width: <xsl:value-of select="$width-label"/>; }
</xsl:if>
<xsl:if test="$width-string != ''">
	.string {width: <xsl:value-of select="$width-string"/>; }
</xsl:if>
<xsl:if test="$width-comment != ''">
	.comment {width: <xsl:value-of select="$width-comment"/>; }
</xsl:if>
<xsl:if test="$width-stylename != ''">
	.stylename {width: <xsl:value-of select="$width-stylename"/>; }
</xsl:if>
	.dim {color: silver; }
	.bright {color: red; }
<xsl:if test="$useCSSstyles != ''">
	<xsl:apply-templates select="/ftml/head/styles/*" />
</xsl:if>
		</style>
	</head>
	<body onload='init()'>
		<h1><xsl:value-of select="/ftml/head/title"/></h1>
		<p><xsl:value-of select="/ftml/head/comment"/></p>
		<xsl:apply-templates select="/ftml/testgroup"/>
	</body>
</html>
</xsl:template>

<!-- 
	Build CSS style for FTML style element, but only for non-empty @feats
-->
<xsl:template match="style">
<xsl:if test="@feats">
	.string_<xsl:value-of select="@name"/> {
		font-family: TestFont; font-size: <xsl:value-of select="$font-scale"/>%;
		-moz-font-feature-settings: <xsl:value-of select="@feats"/>;
		-ms-font-feature-settings: <xsl:value-of select="@feats"/>;
		-webkit-font-feature-settings: <xsl:value-of select="@feats"/>;
		font-feature-settings: <xsl:value-of select="@feats"/>;
<xsl:if test="$width-string != ''">
		width: <xsl:value-of select="$width-string"/>;
</xsl:if>
	}
</xsl:if>
</xsl:template>

<!-- 
	Process a testgroup, emitting a table containing all test records from the group
-->
<xsl:template match="testgroup">
	<h2><xsl:value-of select="@label"/></h2>
	<p><xsl:value-of select="comment"/></p>
	<table>
		<tbody>
			<xsl:apply-templates/>
		</tbody>
	</table>
</xsl:template>

<!-- 
	Emit html lang and either css class or font-feature-settings for a test 
-->
<xsl:template match="style" mode="getLang">
	<xsl:if test="@lang">
		<xsl:attribute name="lang">
			<xsl:value-of select="@lang"/>
		</xsl:attribute>
	</xsl:if>
	<xsl:if test="@feats">
		<xsl:choose>
			<xsl:when test="$useCSSstyles != ''">	
				<xsl:attribute name="class">string_<xsl:value-of select="@name"/></xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="style">
	-moz-font-feature-settings: <xsl:value-of select="@feats"/>;
	-ms-font-feature-settings: <xsl:value-of select="@feats"/>;
	-webkit-font-feature-settings: <xsl:value-of select="@feats"/>;
	font-feature-settings: <xsl:value-of select="@feats"/>;</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<!-- 
	Process a single test record, emitting a table row
-->
<xsl:template match="test">
<tr>
	<xsl:if test="@background">
		<xsl:attribute name="style">background-color: <xsl:value-of select="@background"/>;</xsl:attribute>
	</xsl:if>
	<!-- emit label column -->
	<td class="label">
		<xsl:value-of select="@label"/>
	</td>
	<!-- emit test data column -->
	<td class="string">   <!-- assume default string class -->
		<xsl:if test="@stylename">
			<!-- emit features and lang attributes -->
			<xsl:variable name="styleName" select="@stylename"/>
			<xsl:apply-templates select="/ftml/head/styles/style[@name=$styleName]" mode="getLang"/>
		</xsl:if>
		<xsl:if test="@rtl='True' ">
              <xsl:attribute name="dir">RTL</xsl:attribute>
		</xsl:if>
		<!-- and finally the test data -->
		<xsl:choose>
			<!-- if the test has an <em> marker, the use a special template -->
			<xsl:when test="string[em]">
				<xsl:apply-templates select="string" mode="hasEM"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="string"/>
			</xsl:otherwise>
		</xsl:choose>
	</td>
	<xsl:if test="/ftml/testgroup/test/comment">
		<td class="comment">
			<!-- emit comment -->
			<xsl:value-of select="comment"/>
		</td>
	</xsl:if>
	<xsl:if test="/ftml/testgroup/test/@stylename">
		<td class="stylename">
			<!-- emit style name -->
			<xsl:value-of select="@stylename"/>
		</td>
	</xsl:if>
</tr>
</xsl:template>

<!--  
	suppress all text nodes except those we really want 
-->
<xsl:template match="text()"/>

<!-- 
	for test strings that have no <em> children, emit text nodes without any adornment 
-->
<xsl:template match="string/text()">
	<xsl:value-of select="."/>
</xsl:template>

<!-- 
	for test strings that have <em> children, emit text nodes dimmed 
-->
<xsl:template match="string/text()" mode="hasEM">
	<span class="dim"><xsl:value-of select="."/></span>
</xsl:template>

<!-- 
	for <em> children of test strings, emit the text nodes with no adornment 
-->
<xsl:template match="em/text()" mode="hasEM">
	<!-- <span class="bright"><xsl:value-of select="."/></span> -->
	<xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>

