local _, ns = ...
local P, S, L = ns.SettingsPreview, ns.Settings, ns.L
local R = P.renderers
local function Get(path, default)
    local v = S:GetPath(path)
    if v == nil then return default end
    return v
end
local function Font(path) return Get(path, {}) end
local function Note(c, text) c:Text('note', text or L["Sample appearance"], 8, c.height - 26, c.width - 16, { size = 10 }) end
local function Heading(c, text) c:Text('heading', text, 8, 8, c.width - 16) end
local function Icon(c, id, name, x, y, size)
    local t = c:Texture(id, 'Interface\\Icons\\' .. name, x, y, size, size)
    t:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    return t
end
local function Atlas(c, id, name, x, y, w, h)
    local t = c:Texture(id, nil, x, y, w, h)
    if C_Texture.GetAtlasInfo(name) then t:SetAtlas(name) end
    return t
end

function R.unit(c, spec)
    local style = spec.key == 'uf.frameStyle' and spec.value or (ns.UFRing and ns.UFRing.Style() or 'addon')
    c:Art(P.styles[style] or 'StyleAddon', 4, 4, c.width - 8, math.min(95, c.height - 8))
    if c.height < 120 then return end
    if spec.key == 'uf.palette' then
        local palette = ns.UnitFrames.PALETTES[Get('unitframes.palette', 'flareui')]
        c:Bar('paletteHealth', 12, 130, c.width - 24, 22, 0.8, palette.health)
        c:Bar('paletteMana', 12, 154, c.width - 24, 10, 0.65, palette.mana)
        c:Text('paletteLabel', L["Colour Palette"], 16, 133)
    elseif spec.key == 'uf.simplePet' or spec.key == 'uf.simpleTargetOf' then
        local simple = spec.value or style == 'addon'
        c:Art(simple and 'StyleAddon' or (P.styles[style] or 'StyleAddon'), 28, 122, c.width - 56, 55, 'smallUnit')
        c:Text('smallLabel', spec.key == 'uf.simplePet' and L["Pet"] or L["Target of Target"], 12, 104)
    elseif spec.key == 'uf.hidePlayer' then
        c.objects.art:SetAlpha((tonumber(spec.value) or 100) / 100)
    elseif spec.key == 'uf.fullNames' then
        c:Text('fullName', spec.value and 'Aeloria Dawnwhisper' or 'Aeloria', 12, 135, c.width - 24, Font('unitframes.font'))
    end
    Note(c, L["Style sample at default settings"])
end

-- The square map is FlareUI's shipped capture. Round uses the same terrain sample, cropped and
-- masked, with the client's native minimap art; no live minimap is moved or sampled.
function R.minimap(c, spec)
    local style = spec.key == 'mm.style' and spec.value or Get('minimap.style', 'square')
    local size = math.min(c.width - 20, c.height - (c.height > 120 and 48 or 8))
    local x, y = (c.width - size) / 2, 4
    if spec.key == 'mm.coordsHover' then
        -- A terrain-only specimen avoids baking the capture's coordinates into both toggle states.
        local terrain = c:Texture('coordinateTerrain', P.MEDIA .. 'Art\\Tour\\Minimap.png', x, y, size, size)
        terrain:SetTexCoord(16 / 512, 267 / 512, 35 / 512, 248 / 512)
        if not Get('minimap.coordsOnHover') then c:Text('coords', '48.2, 36.7', 65, size - 16, 110, Font('minimap.clockFont')) end
    elseif style == 'square' then
        c:Art('Minimap', x, y, size, size)
    else
        local terrain = c:Texture('roundTerrain', P.MEDIA .. 'Art\\Tour\\Minimap.png', x, y, size, size)
        terrain:SetTexCoord(24 / 512, 256 / 512, 35 / 512, 267 / 512)
        if not c.mapMask then
            c.mapMask = c.frame:CreateMaskTexture()
            c.mapMask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
            terrain:AddMaskTexture(c.mapMask)
        end
        c.mapMask:ClearAllPoints(); c.mapMask:SetAllPoints(terrain)
        local ring = Atlas(c, 'mapRing', 'ui-hud-minimap-frame-generic', x, y, size, size)
        if not C_Texture.GetAtlasInfo('ui-hud-minimap-frame-generic') then
            ring:SetTexture('Interface\\Minimap\\UI-Minimap-Border')
            ring:SetTexCoord(0, 0.7, 0, 0.7)
        end
    end
    if c.height > 120 then
        if spec.key == 'mm.clockStats' then c:Text('stats', Get('minimap.clockStats') and '60 fps · 32 ms' or '12:30', 12, size + 6) end
        if spec.key == 'mm.bag' and Get('minimap.buttonBag') then
            for i = 1, 3 do Icon(c, 'mapButton' .. i, 'INV_Misc_Bag_08', 20 + (i - 1) * 32, size - 35, 24) end
        end
        if spec.key == 'mm.microMenu' and Get('minimap.microMenu') then
            for i, name in ipairs({ 'INV_Helmet_03', 'INV_Misc_Book_09', 'INV_Misc_Map_01' }) do Icon(c, 'micro' .. i, name, 45 + (i - 1) * 38, size - 35, 26) end
        end
        Note(c, spec.key == 'mm.coordsHover' and L["Appearance without hovering the map"] or nil)
    end
end

local auraIcons = { 'Spell_Holy_WordFortitude', 'Spell_Holy_DivineSpirit', 'Spell_Nature_Regeneration' }
local function Auras(c, unit, spec)
    Heading(c, L["Buffs & Debuffs"])
    local prefix = unit and 'unitframes.' or 'auras.'
    local style = Get(prefix .. (unit and 'auraStyle' or 'style'), 'round')
    local timer = Get(prefix .. (unit and 'auraTimer' or 'timer'), 'below')
    local swipe = Get(prefix .. (unit and 'auraSwipe' or 'swipe'), 'border')
    local font = Font(prefix .. (unit and 'auraFont' or 'font'))
    local colored = Get(prefix .. (unit and 'auraTimerColor' or 'timerColor'), false)
    for i, name in ipairs(auraIcons) do
        local b = c:Object('aura' .. i, 'Frame')
        b:SetPoint('TOPLEFT', 16 + (i - 1) * 66, -65)
        -- Use the production aura renderer, including its masks, timer placement and swipe textures.
        ns.AuraLook.Style(b, { size = 46, style = style, swipe = swipe, timer = timer,
            font = font, countFont = Font(prefix .. (unit and 'auraCountFont' or 'countFont')), timerSize = math.max(10, font.size or 10) })
        b.FlareUI_Icon:SetTexture('Interface\\Icons\\' .. name)
        b.FlareUI_Border:SetVertexColor(1, 1, 1)
        b.FlareUI_Count:SetText(i == 2 and '3' or '')
        b.FlareUI_Duration:SetAlpha(0)
        b.FlareUI_PreviewTimer:SetShown(timer ~= 'none')
        b.FlareUI_PreviewTimer:SetText(({ '9s', '24s', '1m' })[i])
        b.FlareUI_PreviewTimer:SetTextColor(1, colored and i == 1 and 0.2 or 1, colored and i == 1 and 0.2 or 1)
        b.FlareUI_Cooldown:SetCooldown(GetTime() - i * 2, 12)
    end
    if spec.key == 'au.skinCDM' then
        c:Text('cdmTitle', L["Cooldown Manager"], 12, 136)
        c:Bar('cdmBar', 12, 160, c.width - 24, 18, 0.65, { 1, 0.5, 0.25 }, Get('auras.skinCDM') and 'FlareUI Flat' or 'Blizzard')
        if Get('auras.skinCDM') then c:Box('cdmBorder', 12, 160, c.width - 24, 18, 'FlareUI Thin', 0) end
    end
    local elapsed = 0
    c.frame:SetScript('OnUpdate', function(_, dt)
        elapsed = elapsed + dt
        if spec.key == 'au.arrive' and Get('auras.arrive') then
            c.objects.aura3:SetAlpha(math.min(1, (elapsed % 3) * 3))
        end
        if elapsed < 12 then return end
        elapsed = 0
        for i = 1, 3 do c.objects['aura' .. i].FlareUI_Cooldown:SetCooldown(GetTime() - i * 2, 12) end
    end)
    Note(c)
end
function R.auras(c, spec) Auras(c, false, spec) end
function R.unitAuras(c, spec) Auras(c, true, spec) end

function R.chat(c, spec)
    local top, height = 43, 125
    c:Box('chatBox', 4, top, c.width - 8, height, Get('chat.borderTexture'), Get('chat.opacity', 0.5))
    c:Text('chatTab', L["General"], 12, top + 8, c.width - 24, Font('chat.tabFont'))
    local stamp = Get('chat.betterTimestamps') and '[12:30] ' or ''
    local channel = Get('chat.shortChannels') and '[G] ' or '[' .. L["Guild"] .. '] '
    local name = Get('chat.formatPlayer') and '[|cff69ccf0Flareui|r]' or '[Flareui-Realm]'
    if Get('chat.showLevel') then name = '(60) ' .. name end
    local spacing = math.max(Get('chat.increaseLineHeight') and 24 or 19, (Font('chat.chatFont').size or 12) + 4)
    local sampleName = name
    for i, line in ipairs({ '|cff40ff40' .. stamp .. channel .. sampleName .. ': ' .. L["Ready?"] .. '|r',
        '|cff40ff40' .. stamp .. channel .. '[Aeloria]: ' .. L["Ready!"] .. '|r',
        '|cffffd100' .. (Get('chat.formatNPC') and L["Innkeeper"] .. ': ' or L["Innkeeper says: "]) .. L["Welcome!"] .. '|r' }) do
        if i * spacing <= height - 54 then
            local t = c:Text('chatLine' .. i, line, 12, top + 30 + (i - 1) * spacing, c.width - 24, Font('chat.chatFont'))
            t:SetWordWrap(false)
        end
    end
    local position = Get('chat.editBoxPosition', 'inside')
    local editY = position == 'above' and top - 27 or position == 'below' and top + height + 4 or top + height - 24
    c:Box('editBox', 8, editY, c.width - 16, 23, 'FlareUI Thin', Get('chat.editBoxOpacity', 1))
    c:Text('editText', L["Say:"] .. ' ...', 14, editY + 5, c.width - 28, Font('chat.editBoxFont'))
    c.objects.editText:SetWordWrap(false)
    local buttonX = 12
    for i, def in ipairs({ { 'chat.socialHide', 'ChatSocial', true }, { 'chat.channelHide', 'ChatChannels', true },
        { 'chat.menuHide', 'ChatOptions', true }, { 'chat.showVolume', 'Volume-Speaker-High', false } }) do
        if Get(def[1], not def[3]) ~= def[3] then
            c:Texture('chatHeader' .. i, P.MEDIA .. 'Icons\\' .. def[2], buttonX, 13, 18, 18)
            buttonX = buttonX + 24
        end
    end
    if Get('chat.copyButton') then c:Text('copyButton', L["Copy"], c.width - 49, 13, 45, { size = 10 }) end
    if not Get('chat.hideCombatLog', false) and spec.key == 'ch.combatLog' then c:Text('combatTab', L["Combat Log"], 85, top + 8, c.width - 97, Font('chat.tabFont')) end
    if spec.key == 'ch.minAlpha' then c.frame:SetAlpha(Get('chat.minAlpha', 0)) end
    Note(c)
end

function R.tooltip(c, spec)
    local outer = c
    if not outer.tooltipCanvas then
        outer.tooltipCanvas = P.Create(outer.frame, outer.width, outer.height)
        outer.objects.tooltipCanvasFrame = outer.tooltipCanvas.frame
    end
    c = outer.tooltipCanvas
    c:Reset()
    local scale = spec.key == 'tt.scale' and Get('tooltips.scale', 1) / 1.5 or 1
    c.frame:SetScale(scale)
    c.frame:ClearAllPoints(); c.frame:SetPoint('TOPLEFT', (outer.width - c.width * scale) / 2, 0); c.frame:Show()
    local item = spec.key == 'tt.shortItemStats' or spec.key == 'tt.ids'
    local box = c:Object('tooltip', 'Frame', 'BackdropTemplate')
    box:SetPoint('TOPLEFT', 8, -25); box:SetSize(c.width - 16, 155)
    box:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8X8', edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border', edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    box:SetBackdropColor(0.05, 0.05, 0.06, 0.9)
    box:SetBackdropBorderColor(0.8, 0.6, 0.34, 1)
    if Get('tooltips.borderByClass') or Get('tooltips.borderByQuality') then box:SetBackdropBorderColor((item and 0.64 or 0.41) * 0.85, (item and 0.21 or 0.8) * 0.85, (item and 0.93 or 0.94) * 0.85, 1) end
    local layout = NineSliceUtil and NineSliceUtil.GetLayout('TooltipDefaultLayout')
    if layout then
        -- Use the client's tooltip art, as the production tooltip module does. The backdrop above
        -- is only for clients without this layout, not a replacement for their native NineSlice.
        box:SetBackdrop(nil)
        NineSliceUtil.ApplyLayout(box, layout)
        local r, g, b = 0.8, 0.6, 0.34
        if Get(item and 'tooltips.borderByQuality' or 'tooltips.borderByClass') then
            r, g, b = (item and 0.64 or 0.41) * 0.85, (item and 0.21 or 0.8) * 0.85, (item and 0.93 or 0.94) * 0.85
        end
        for _, name in ipairs({ 'TopLeftCorner', 'TopRightCorner', 'BottomLeftCorner', 'BottomRightCorner', 'TopEdge', 'BottomEdge', 'LeftEdge', 'RightEdge' }) do
            if box[name] then box[name]:SetVertexColor(r, g, b, 1) end
        end
        if box.Center then box.Center:SetVertexColor(0.05, 0.05, 0.06, 0.9) end
    end
    c:Text('tooltipTitle', item and '|cffa335ee' .. L["Sample item"] .. '|r' or (Get('tooltips.nameColor') == 'class' and '|cff69ccf0Flareui|r' or 'Flareui'), 16, 35, c.width - 32, Font('tooltips.titleFont')):SetWordWrap(false)
    local lines = {}
    if item then
        lines = { L["Chest"], Get('tooltips.shortItemStats') and '+12 ' .. L["Intellect"] or L["Increases Intellect by 12."] }
        if Get('tooltips.showItemID') then lines[#lines + 1] = 'ID: 12345' end
    else
        if Get('tooltips.showGuild') then lines[#lines + 1] = '<FlareUI>' .. (Get('tooltips.showGuildRank') and ' · ' .. L["Member"] or '') end
        lines[#lines + 1] = L["Level 60 Mage"]
        if not Get('tooltips.hideFaction') then lines[#lines + 1] = L["Horde"] end
        if Get('tooltips.showTarget') then lines[#lines + 1] = L["Target"] .. ': Aeloria' end
        if Get('tooltips.showThreat') then lines[#lines + 1] = L["Threat"] .. ': 65%' end
    end
    local font = Font('tooltips.contentFont')
    local count = math.max(1, math.floor(92 / ((font.size or 12) + 2)))
    while #lines > count do table.remove(lines) end
    c:Text('tooltipText', table.concat(lines, '\n'), 16, 58, c.width - 32, font):SetWordWrap(false)
    if not item and not Get('tooltips.hideHealthBar') then c:Bar('tooltipHealth', 13, 160, c.width - 26, 10, 0.8, ns.HEALTH_GREEN) end
    if spec.key == 'tt.anchor' then
        c:Text('cursor', '+', Get('tooltips.anchor') == 'cursorOffset' and 4 or c.width - 24, 184, 20)
        c:Text('anchorLabel', Get('tooltips.anchor') == 'cursorOffset' and L["At the cursor"] or L["Default position"], 24, 184, c.width - 48, { size = 10 })
    end
    Note(outer)
end

function R.tracker(c, spec)
    c:Box('trackerBox', 4, 12, c.width - 8, 184, Get('objectivetracker.borderTexture'), Get('objectivetracker.opacity', 0.5))
    c:Text('trackerTitle', L["Quests"] .. (Get('objectivetracker.showCount') and ' (2)' or ''), 12, 22, c.width - 24, Font('objectivetracker.headerFont'))
    if spec.key == 'qt.minimizeButton' then
        c.objects.trackerBox:SetHeight(35)
        c.objects.trackerTitle:SetText(Get('objectivetracker.minimizeStyle') == 'button' and '+' or L["Quests"])
        Note(c, L["Minimized appearance"]); return
    end
    local y = 48
    if Get('objectivetracker.zoneHeaders') then c:Text('zone', L["Elwynn Forest"], 12, y, c.width - 24); y = y + 22 end
    for i, title in ipairs({ L["A Threat Within"], L["Kobold Camp Cleanup"] }) do
        local text = (Get('objectivetracker.hideLevel') and '' or '[5] ') .. title .. (Get('objectivetracker.showTags') and ' [G]' or '')
        local t = c:Text('quest' .. i, text, 12, y, c.width - 24, Font('objectivetracker.titleFont'))
        t:SetWordWrap(Get('objectivetracker.wrapText', true)); t:SetMaxLines(2)
        local h = math.max(18, t:GetStringHeight())
        if y + h + (Font('objectivetracker.objectiveFont').size or 12) > 190 then t:Hide(); break end
        c:Text('objective' .. i, i == 1 and L["Speak to the Marshal"] or '4/8 ' .. L["Kobolds defeated"], 20, y + h, c.width - 32, Font('objectivetracker.objectiveFont')):SetWordWrap(false)
        y = y + h + 30
    end
    if Get('objectivetracker.focusButtons') then c:Text('focus', '+', c.width - 23, 22, 18) end
    if Get('objectivetracker.playButtons') then c:Text('play', '>', c.width - 43, 22, 18) end
    Note(c)
end

function R.meter(c, spec)
    c:Box('meterBox', 4, 25, c.width - 8, 151, Get('damagemeter.borderTexture'), Get('damagemeter.opacity', 0.5))
    local threat = spec.key:find('threat') or spec.key:find('pull') or spec.key == 'dm.tankLead'
    c:Text('meterTitle', threat and L["Threat"] or L["Damage"], 12, 34, c.width - 24, Font('damagemeter.headerFont'))
    for i, name in ipairs({ 'Flareui', 'Aeloria', 'Thorne' }) do
        local y = 61 + (i - 1) * 33
        c:Bar('meterBar' .. i, 10, y, c.width - 20, 27, 1 - (i - 1) * 0.22, ({ { 0.41, 0.8, 0.94 }, { 0.77, 0.12, 0.23 }, { 1, 0.49, 0.04 } })[i])
        local mode = Get('damagemeter.threatValueDisplay', 'both')
        local value = threat and (mode == 'percent' and '75%' or mode == 'value' and '12.5k' or '12.5k (75%)') or '12.5k'
        if threat and i == 1 and Get('damagemeter.threatTankLead') then value = value:gsub('75%%', '+25%%') end
        c:Text('meterName' .. i, name .. '  ' .. value, 15, y + 6, c.width - 30, Font('damagemeter.barFont')):SetWordWrap(false)
    end
    if threat and Get('damagemeter.threatPullLine') then
        local line = c:Texture('pullLine', 'Interface\\Buttons\\WHITE8X8', c.width - 42, 60, 2, 94)
        line:SetVertexColor(1, 0.2, 0.1)
    end
    if spec.key == 'dm.pullFlash' and Get('damagemeter.threatPullFlash') then
        local flash = c:Texture('pullFlash', 'Interface\\Buttons\\WHITE8X8', 10, 61, c.width - 20, 27, true)
        flash:SetDrawLayer('OVERLAY', 6); flash:SetVertexColor(1, 0.15, 0.1); flash:SetBlendMode('ADD')
        local elapsed = 0
        c.frame:SetScript('OnUpdate', function(_, dt)
            elapsed = elapsed + dt
            flash:SetAlpha(0.55 * math.abs(math.sin(elapsed * math.pi / 0.8)))
        end)
    end
    if threat and Get('damagemeter.threatTankLead') then c:Text('tankLead', L["Tank lead"] .. ': +25%', 12, 178, c.width - 24, { size = 10 }) end
    if spec.key == 'dm.chatTab' and Get('damagemeter.chatTab') then c:Text('meterChatTab', L["General"] .. '  |cffffd100' .. L["Damage"] .. '|r', 12, 7) end
    if Get('damagemeter.combatTimer') then c:Text('combatTime', '01:24', c.width - 52, 34, 46, { size = 10 }) end
    if Get('damagemeter.readyCheckButton') then c:Texture('readyCheck', P.MEDIA .. 'Icons\\DMReadyCheck', 151, 8, 18, 18) end
    if Get('damagemeter.countdownButton') then c:Texture('countdown', P.MEDIA .. 'Icons\\DMCountdown', 176, 8, 18, 18) end
    if spec.key == 'dm.minAlpha' then c.frame:SetAlpha(Get('damagemeter.minAlpha', 0)) end
    Note(c)
end

function R.actions(c, spec)
    c:Art('ActionBars', 4, 10, c.width - 8, 48)
    if spec.key == 'ab.hideGryphons' or spec.key == 'ab.gryphonsBehind' then
        local hide = Get('visibility.hideEndCaps')
        local behind = Get('actionbars.gryphonsBehind')
        local sample = c.objects.art
        -- The central strip excludes the gryphons. The full capture shows their native placement.
        if hide then sample:SetTexCoord(200 / 1024, 705 / 1024, 0, 195 / 256) end
        if behind and not hide then
            -- Show overlap order using the production button-frame atlas over the left gryphon.
            Atlas(c, 'overGryphon', 'UI-HUD-ActionBar-IconFrame', 28, 21, 34, 34)
        end
    end
    for i, name in ipairs({ 'Spell_Frost_FrostBolt02', 'Spell_Fire_FireBolt02', 'Spell_Holy_Heal', 'INV_Misc_QuestionMark' }) do
        local x, y, size = 12 + (i - 1) * 51, 95, 42
        local icon = Icon(c, 'action' .. i, name, x, y, size)
        if i == 2 and Get('actionbars.dimOnCooldown') then icon:SetDesaturated(true); icon:SetVertexColor(0.45, 0.45, 0.45) end
        if i == 3 and Get('actionbars.colors.enableRange') then icon:SetVertexColor(1, 0.2, 0.2) end
        if Get('actionbars.buttonArt') then Atlas(c, 'actionBorder' .. i, 'UI-HUD-ActionBar-IconFrame', x, y, size, size) end
        if not Get('actionbars.hideHotkeys') then c:Text('hotkey' .. i, Get('actionbars.cleanKeybinds') and 'S-' .. i or 'SHIFT-' .. i, x, y, size, Font('actionbars.hotkeyFont')) end
        if not Get('actionbars.hideMacroText') then c:Text('macro' .. i, L["Spell"], x, y + 29, size, Font('actionbars.macroFont')) end
    end
    if spec.key == 'ab.procGlow' and Get('actionbars.procGlow') then
        local glow = c:Object('procGlow', 'Frame', 'ActionButtonSpellAlertTemplate')
        glow:SetPoint('TOPLEFT', 3, -86); glow:SetSize(60, 60)
        if glow.ProcStartAnim then glow.ProcStartAnim:Play() end
    end
    Note(c)
end

function R.xp(c)
    Heading(c, L["Experience"])
    c:Bar('xp', 10, 85, c.width - 20, 22, 0.65, { 0.55, 0.25, 0.8 }, Get('actionbars.xpbar.texture'))
    local mode = Get('actionbars.xpbar.textFormat', 'VALUES')
    c:Text('xpText', ({ VALUES = '6,500 / 10,000', PERCENT = '65%', BOTH = '6,500 / 10,000 (65%)', REMAINING = '3,500' })[mode], 14, 90, c.width - 28)
    if Get('actionbars.xpbar.questXP') then c:Bar('questXp', c.width * 0.65, 85, 30, 22, 1, { 0.8, 0.65, 0.2 }) end
    Note(c)
end

function R.resources(c, spec)
    Heading(c, L["Resource Bars"])
    local key = spec.key:match('^rb%.(.+)$') or 'health'
    local db = Get('unitframes.resource.bars.' .. key, {})
    if key == 'combo' then
        for i = 1, 5 do
            local point = c.objects['comboPoint' .. i]
            if not point then point = ns.CreateComboPoint(c.frame, i, 22, false); c.objects['comboPoint' .. i] = point end
            point:ClearAllPoints(); point:SetPoint('TOPLEFT', 18 + (i - 1) * 38, -83)
            ns.SetComboPoint(point, 3, false); point:Show()
        end
    else
        local color = key == 'health' and ns.HEALTH_GREEN or key:find('swing') and { 0.86, 0.65, 0.39 } or ns.MANA_BLUE
        c:Bar('resource', 10, 85, c.width - 20, 24, 0.65, color, db.texture)
        c:Box('resourceBorder', 10, 85, c.width - 20, 24, db.border, 0)
        c:Text('resourceText', key:find('swing') and '1.8 / 2.6' or '65%', 16, 91, c.width - 32, Font('unitframes.resource.font'))
    end
    Note(c)
end

function R.bags(c)
    Heading(c, L["Bags"])
    local columns = Get('tweaks.bagColumns', 0); if columns == 0 then columns = 10 end
    local gap = Get('tweaks.bagGaps') and 5 or 1
    local scale = math.min(1, (c.width - 16) / (columns * 32 + (columns - 1) * gap))
    local size = 32 * scale
    gap = gap * scale
    for i = 1, columns * 3 do
        local x, y = 8 + ((i - 1) % columns) * (size + gap), 45 + math.floor((i - 1) / columns) * (size + gap)
        Icon(c, 'bagItem' .. i, ({ 'INV_Potion_54', 'INV_Misc_Bag_08', 'INV_Sword_04', 'INV_Misc_LeatherScrap_01' })[(i - 1) % 4 + 1], x, y, size)
        local border = c:Box('bagBorder' .. i, x, y, size, size, Get('tweaks.bagThickBorders') and 'FlareUI Thick' or 'FlareUI Thin', 0)
        local thick = Get('tweaks.bagThickBorders')
        local outset = (thick and 2 or 3) * scale
        border:ClearAllPoints(); border:SetPoint('TOPLEFT', x - outset, -(y - outset)); border:SetSize(size + 2 * outset, size + 2 * outset)
        border:SetBackdrop({ edgeFile = LibStub('LibSharedMedia-3.0'):Fetch('border', thick and 'FlareUI Thick' or 'FlareUI Thin'), edgeSize = (thick and 16 or 8) * scale })
        border:SetFrameLevel(c.frame:GetFrameLevel() + 1)
        if Get('tweaks.bagRarityBorders') then border:SetBackdropBorderColor(i % 2 == 0 and 0.1 or 0.64, i % 2 == 0 and 1 or 0.21, i % 2 == 0 and 0.1 or 0.93, 1) end
        if i == 1 and Get('tweaks.bagJunkIcon') then Atlas(c, 'junk', 'bags-junkcoin', x, y, size * 0.5, size * 0.5) end
        if i == 2 and Get('tweaks.bagUpgradeArrow') then Atlas(c, 'upgrade', 'bags-greenarrow', x + size * 0.5, y + size * 0.5, size * 0.5, size * 0.5) end
    end
    if Get('tweaks.bagButtons') then
        for i = 1, 4 do Icon(c, 'bagButton' .. i, 'INV_Misc_Bag_08', 10 + (i - 1) * 35, 169, 26) end
    end
    Note(c)
end

function R.nameplate(c)
    Heading(c, L["Nameplates"])
    if not Get('tweaks.nameplateHideNames') then c:Text('nameplateName', (Get('tweaks.nameplateHideLevel') and Get('tweaks.nameplateLevelName') and '12 ' or '') .. L["Forest Spider"], 22, 69) end
    c:Bar('nameplate', 16, 94, c.width - 32, 17, 0.72, { 0.8, 0.15, 0.12 })
    if not Get('tweaks.nameplateHideLevel') then c:Text('nameplateLevel', '12', c.width - 35, 96, 30) end
    if Get('tweaks.nameplateQuest') then Atlas(c, 'questBadge', 'QuestNormal', 2, 92, 15, 19) end
    if Get('tweaks.nameplateCombo') then
        for i = 1, 3 do
            local p = c.objects['plateCombo' .. i]
            if not p then p = ns.CreateComboPoint(c.frame, i, 14, false); c.objects['plateCombo' .. i] = p end
            p:ClearAllPoints(); p:SetPoint('TOPLEFT', 75 + (i - 1) * 24, -121); ns.SetComboPoint(p, 3, false); p:Show()
        end
    end
    Note(c)
end

function R.radial(c, spec)
    local size = math.min(c.width - 12, c.height - 36) * Get('radialmenu.scale', 1) / 1.5
    local x = (c.width - size) / 2
    if spec.key == 'rm.position' and Get('radialmenu.position') == 'cursor' then x = 4 end
    c:Art('Radial', x, 4, size, size)
    if not Get('radialmenu.showNames', true) then
        -- This shipped capture's single label is outside the wheel, at x=437..500, y=235..263.
        -- Cover just that label with the same dark preview surface, retaining all four icons.
        local cover = c:Texture('radialLabelCover', 'Interface\\Buttons\\WHITE8X8', x + size * 0.874, 4 + size * 0.47, size * 0.126, size * 0.06)
        cover:SetVertexColor(0.035, 0.03, 0.02)
    end
    Note(c, L["Style sample at default settings"])
end

function R.font(c, spec)
    local cfg = Font(spec.font)
    Heading(c, L["Font Preview"])
    c:Text('fontName', 'Flareui · Aeloria', 12, 53, c.width - 24, cfg)
    c:Text('fontNumbers', '12,345 / 20,000  65%', 12, 98, c.width - 24, cfg)
    c:Text('fontTime', '9s  24s  1m  12:30', 12, 143, c.width - 24, cfg)
    Note(c)
end
