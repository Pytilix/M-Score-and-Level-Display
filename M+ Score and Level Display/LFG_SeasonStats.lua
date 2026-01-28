--[[
    ============================================================================
    FPS & MS Monitor
    Copyright (c) 2021-2026 Pytilix
    All rights reserved.

    This Add-on and its source code are proprietary. 
    Unauthorized copying, modification, or distribution of this file, 
    via any medium, is strictly prohibited.
    
    The source code is provided for personal use and educational purposes 
    only, as per Blizzard's UI Add-On Development Policy.
    ============================================================================
--]]


local function CreateStatsPanel()
    -- Erstellen des Hauptframes mit Backdrop-Unterstützung
    local f = CreateFrame("Frame", "MPlusSeasonDashboard", PVEFrame, "BackdropTemplate")
    f:SetSize(360, 310) -- Breite und Höhe optimal angepasst
    f:SetPoint("TOPLEFT", PVEFrame, "TOPRIGHT", 2, -10) -- Direkt rechts angedockt
    
    -- Ein schlichtes, dunkles Fenster-Design
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8", -- Flacher Hintergrund
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Dezenter Rand
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(0, 0, 0, 0.85) -- Sattes Schwarz mit leichter Transparenz
    f:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) -- Grauer, edler Rand

    -- Titel: Saison Score
    f.header = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.header:SetPoint("TOPLEFT", 15, -15)
    
    f.rows = {}
    for i = 1, 10 do
        local row = CreateFrame("Frame", nil, f)
        row:SetSize(330, 24)
        row:SetPoint("TOPLEFT", 12, -40 - (i * 24))

        -- Dungeon Icon
        row.icon = row:CreateTexture(nil, "OVERLAY")
        row.icon:SetSize(20, 20)
        row.icon:SetPoint("LEFT", 0, 0)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        -- Text (Name, Stufe, Rating)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 10, 0)
        row.text:SetJustifyH("LEFT")
        
        f.rows[i] = row
    end

    f.UpdateData = function()
        local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
        if not summary or not summary.runs then return end

        f.header:SetText("Saison-Score: |cff00ff00" .. summary.currentSeasonScore .. "|r")

        for i, run in ipairs(summary.runs) do
            if f.rows[i] then
                local mapName, _, _, texture = C_ChallengeMode.GetMapUIInfo(run.challengeModeID)
                f.rows[i].icon:SetTexture(texture or "Interface\\Icons\\Inv_misc_questionmark")
                
                -- Farbliche Abstufung für das Level
                local levelColor = "|cffffffff" -- Weiß
                if run.bestRunLevel >= 7 then levelColor = "|cff0070dd" end -- Blau
                if run.bestRunLevel >= 10 then levelColor = "|cffa335ee" end -- Lila
                if run.bestRunLevel >= 15 then levelColor = "|cffff8000" end -- Orange

                f.rows[i].text:SetText(string.format("|cffffd100%s:|r %s+%d|r (|cffffffff%d|r)", 
                    mapName or "Lade...", levelColor, run.bestRunLevel, run.mapScore))
                f.rows[i]:Show()
            end
        end
    end

    -- Sichtbarkeit steuern
    f:SetScript("OnShow", f.UpdateData)
    PVEFrame:HookScript("OnShow", function() f:Show() end)
    PVEFrame:HookScript("OnHide", function() f:Hide() end)

    return f
end

local addonFrame = CreateStatsPanel()