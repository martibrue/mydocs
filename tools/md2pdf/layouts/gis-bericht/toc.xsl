<?xml version="1.0" encoding="UTF-8"?>
<!--
  toc.xsl – Inhaltsverzeichnis im Stil der Word-Vorlage

  wkhtmltopdf sammelt alle Überschriften in einer XML-Struktur (outline)
  und wandelt sie mit dieser XSL-Vorlage in eine HTML-Seite um.
  Grundlage: Standardvorlage von wkhtmltopdf (Option dump-default-toc-xsl)
  Achtung: In XML-Kommentaren sind zwei Bindestriche hintereinander verboten.

  Jeder Eintrag: Nummer | Titel ......... Seite
  - Kapitel (1. Ebene) fett, mit Punkt nach der Nummer ("1.")
  - Die Punktlinie entsteht durch einen gepunkteten unteren Rand der Zeile;
    Titel und Seitenzahl haben einen weissen Hintergrund und verdecken die
    Linie dort, wo Text steht.
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:outline="http://wkhtmltopdf.org/outline"
                xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
              indent="yes" />

  <xsl:template match="outline:outline">
    <html>
      <head>
        <title>Inhaltsverzeichnis</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <style>
          body { font-family: "Segoe UI", Arial, sans-serif; font-size: 10pt; margin: 0; }
          h1   { font-size: 14pt; margin: 28px 0 22px 0; }
          ul   { list-style: none; margin: 0; padding: 0; }
          a    { text-decoration: none; color: #000; }

          .zeile  { border-bottom: 1px dotted #000; margin-top: 6px; height: 1.05em; }
          .nr, .titel, .seite { background: #fff; position: relative; top: 0.25em; }
          .nr     { display: inline-block; width: 2.2em; }
          .seite  { float: right; padding-left: 3px; }
          .titel  { padding-right: 3px; }
          .ebene1 { font-weight: bold; margin-top: 10px; }
        </style>
      </head>
      <body>
        <h1>Inhaltsverzeichnis</h1>
        <ul><xsl:apply-templates select="outline:item/outline:item"/></ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="outline:item">
    <!-- Ebene: 1 = Kapitel, 2 = Unterkapitel, … -->
    <xsl:variable name="ebene" select="count(ancestor::outline:item)"/>
    <!-- Titel enthält die Nummer von pandoc, z. B. "1.2 Fall 2": hier trennen -->
    <xsl:variable name="nr"    select="substring-before(normalize-space(@title), ' ')"/>
    <xsl:variable name="text"  select="substring-after(normalize-space(@title), ' ')"/>

    <li>
      <!-- Nur Einträge mit Kapitelnummer (nur Ziffern und Punkte) anzeigen.
           Damit fällt die Überschrift "Inhaltsverzeichnis" dieser Seite weg,
           die wkhtmltopdf sonst selbst als ersten Eintrag aufnimmt. -->
      <xsl:if test="$nr != '' and translate($nr, '0123456789.', '') = ''">
        <div class="zeile ebene{$ebene}">
          <span class="seite"><xsl:value-of select="@page"/></span>
          <a>
            <xsl:if test="@link">
              <xsl:attribute name="href"><xsl:value-of select="@link"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@backLink">
              <xsl:attribute name="name"><xsl:value-of select="@backLink"/></xsl:attribute>
            </xsl:if>
            <span class="nr">
              <xsl:value-of select="$nr"/>
              <xsl:if test="$ebene = 1">.</xsl:if>
            </span>
            <span class="titel"><xsl:value-of select="$text"/></span>
          </a>
        </div>
      </xsl:if>
      <ul>
        <xsl:comment>verhindert selbstschliessende Tags in QtXmlPatterns</xsl:comment>
        <xsl:apply-templates select="outline:item"/>
      </ul>
    </li>
  </xsl:template>
</xsl:stylesheet>
