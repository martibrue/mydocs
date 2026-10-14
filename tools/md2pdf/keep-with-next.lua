--[[
keep-with-next.lua – Pandoc-Lua-Filter

Zweck:
  Verhindert, dass eine Überschrift allein am Seitenende steht.

Funktionsweise:
  Der Filter geht alle Blöcke des Dokuments der Reihe nach durch.
  Trifft er auf eine Überschrift, packt er sie zusammen mit dem
  nächsten Block (z. B. Absatz, Tabelle, Liste oder Bild) in einen
  gemeinsamen Container (<div class="keep">).
  Folgen mehrere Überschriften direkt aufeinander (z. B. ## und ###),
  kommen alle zusammen mit dem ersten Inhaltsblock in denselben Container.

  Im CSS sorgt  .keep { page-break-inside: avoid; }  dafür, dass dieser
  Container nicht über einen Seitenumbruch getrennt wird. Passt er nicht
  mehr auf die Seite, rutscht er als Ganzes auf die nächste Seite.

Aufruf:
  pandoc ... --lua-filter keep-with-next.lua ...
]]

-- Prüft, ob ein Block nur aus einem Bild besteht
-- (je nach Pandoc-Version als "Figure" oder als Absatz mit einem einzelnen Bild)
local function is_image(block)
  if block.t == "Figure" then return true end
  return block.t == "Para" and #block.content == 1 and block.content[1].t == "Image"
end

function Blocks(blocks)
  local result = {}    -- neue Blockliste, die zurückgegeben wird
  local i = 1

  while i <= #blocks do
    if blocks[i].t == "Header" then
      -- Überschrift(en) sammeln
      local group = {}
      while i <= #blocks and blocks[i].t == "Header" do
        table.insert(group, blocks[i])
        i = i + 1
      end
      -- ersten Inhaltsblock nach der Überschrift dazunehmen (falls vorhanden)
      if i <= #blocks then
        table.insert(group, blocks[i])
        i = i + 1
        -- Sonderfall: Überschrift → kurzer Text → Bild
        -- Folgt auf den Text direkt ein Bild, gehört es auch noch dazu
        if not is_image(group[#group]) and i <= #blocks and is_image(blocks[i]) then
          table.insert(group, blocks[i])
          i = i + 1
        end
      end
      -- Gruppe als <div class="keep"> einfügen
      table.insert(result, pandoc.Div(group, pandoc.Attr("", {"keep"})))
    else
      -- alle anderen Blöcke unverändert übernehmen
      table.insert(result, blocks[i])
      i = i + 1
    end
  end

  return result
end
