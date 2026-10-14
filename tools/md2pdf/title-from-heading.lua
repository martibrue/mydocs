--[[
title-from-heading.lua – Pandoc-Lua-Filter

Zweck:
  Macht die erste #-Überschrift einer md-Datei zum Dokumenttitel und
  hebt alle übrigen Überschriften um eine Ebene an:
    #   Titel        -> Dokumenttitel (Titelseite, Kopfzeile), verschwindet aus dem Text
    ##  Kapitel      -> Ebene 1  (mit --number-sections: 1, 2, …)
    ### Unterkapitel -> Ebene 2  (1.1, 1.2, …)

Warum ein eigener Filter statt der pandoc-Option --shift-heading-level-by=-1?
  Die Option verhält sich je nach pandoc-Version unterschiedlich, wenn im
  YAML-Kopfblock bereits ein "title" steht (die Überschrift bleibt dann
  teilweise als Absatz im Text). Der Filter verhält sich immer gleich.

Regeln:
  - Steht ein "title" im YAML-Kopfblock, hat dieser Vorrang. Die #-Überschrift
    wird trotzdem aus dem Text entfernt.
  - Nur eine #-Überschrift ganz am Anfang des Dokuments wird zum Titel.

Aufruf:
  pandoc ... --lua-filter title-from-heading.lua ...
]]

function Pandoc(doc)
  local blocks = doc.blocks

  -- 1. Erste Überschrift der Ebene 1 am Dokumentanfang zum Titel machen
  if #blocks > 0 and blocks[1].t == "Header" and blocks[1].level == 1 then
    if doc.meta.title == nil then
      doc.meta.title = pandoc.MetaInlines(blocks[1].content)
    end
    blocks:remove(1)
  end

  -- 2. Alle übrigen Überschriften eine Ebene anheben (mindestens Ebene 1)
  doc.blocks = blocks:walk({
    Header = function(h)
      h.level = math.max(h.level - 1, 1)
      return h
    end
  })

  return doc
end
