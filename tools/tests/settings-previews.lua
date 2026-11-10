-- Run from the repository root: luajit tools/tests/settings-previews.lua
local ns = { L = setmetatable({}, { __index = function(_, k) return k end }) }
local values = { ['unitframes.palette'] = 'flareui' }
ns.Settings = { GetPath = function(_, key) return values[key] end }
assert(loadfile('Settings/Preview.lua'))('FlareUI', ns)
local P = assert(ns.SettingsPreview)
local function row(key) return { key = key, module = key:match('^([^.]+)'), Get = function() return 'forever' end } end
assert(P.Resolve(row('uf.frameStyle')).kind == 'unit')
assert(P.Resolve(row('uf.frameStyle'), 'addon').value == 'addon')
assert(P.Resolve(row('mm.style'), 'round').value == 'round')
assert(P.Resolve(row('qol.autoAcceptQuests')) == nil)
assert(P.Resolve(row('qol.bagGaps')).kind == 'bags')
assert(P.Resolve(row('qol.npLevel')).kind == 'nameplate')
assert(P.Resolve(row('au.timer')).kind == 'auras')
assert(P.Resolve(row('uf.auraShape')).kind == 'unitAuras')
assert(P.Resolve(row('ch.editBox')).kind == 'chat')
assert(P.Resolve(row('tt.healthBar')).kind == 'tooltip')
assert(P.Resolve(row('qt.wrap')).kind == 'tracker')
assert(P.Resolve(row('dm.pullLine')).kind == 'meter')
assert(P.Resolve(row('ab.buttonArt')).kind == 'actions')
assert(P.Resolve(row('rb.combo')).kind == 'resources')
assert(P.Resolve(row('rm.names')).kind == 'radial')
local font = row('ch.font.text.size'); font.previewFont = 'chat.chatFont'
assert(P.Resolve(font).kind == 'font')
assert(P.Resolve(font).font == 'chat.chatFont')
assert(P.Resolve(row('qol.fastLoot')) == nil)
assert(P.Resolve(row('ab.autoRanks')) == nil)
assert(values['unitframes.palette'] == 'flareui')
print('PASS: visual routing, font metadata, style overrides and behavioural exclusions')

-- A small WoW widget double records rendering, visibility, allocation and animation lifecycle.
-- It intentionally errors on unknown methods instead of silently accepting misspelled APIs.
local allocated = 0
local Widget = {}; Widget.__index = Widget
local function widget(parent)
    allocated = allocated + 1
    return setmetatable({ parent = parent, shown = true, scripts = {}, points = {}, level = 1 }, Widget)
end
function Widget:CreateTexture() return widget(self) end
function Widget:CreateMaskTexture() return widget(self) end
function Widget:CreateFontString() return widget(self) end
function Widget:SetScript(key, fn) self.scripts[key] = fn end
function Widget:RegisterEvent(key) self.event = key end
function Widget:Hide() self.shown = false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
function Widget:Show() self.shown = true end
function Widget:SetShown(v) if v then self:Show() else self:Hide() end end
function Widget:ClearAllPoints() self.points = {} end
function Widget:SetPoint(...) self.points[#self.points + 1] = { ... } end
function Widget:SetAllPoints(v) self.allPoints = v end
function Widget:SetAlpha(v) self.alpha = v end
function Widget:SetSize(w, h) assert(w > 0 and h > 0); self.width, self.height = w, h end
function Widget:SetWidth(w) self.width = w end
function Widget:SetHeight(h) self.height = h end
function Widget:SetFrameLevel(v) self.level = v end
function Widget:GetFrameLevel() return self.level end
function Widget:SetText(v) self.text = v end
function Widget:GetStringHeight() return 14 end
function Widget:SetTextColor(...) self.textColor = { ... } end
function Widget:SetJustifyH(v) self.justify = v end
function Widget:SetWordWrap(v) self.wrap = v end
function Widget:SetMaxLines(v) self.maxLines = v end
function Widget:SetScale(v) self.scale = v end
function Widget:SetTexture(v) self.texture = v end
function Widget:SetAtlas(v) self.atlas = v end
function Widget:SetTexCoord(...) self.crop = { ... } end
function Widget:SetVertexColor(...) self.tint = { ... } end
function Widget:SetDesaturated(v) self.desaturated = v end
function Widget:SetDrawLayer(...) self.layer = { ... } end
function Widget:SetBlendMode(v) self.blend = v end
function Widget:AddMaskTexture(v) self.mask = v end
function Widget:EnableMouse(v) self.mouse = v end
function Widget:SetBackdrop(v) self.backdrop = v end
function Widget:SetBackdropColor(...) self.bgColor = { ... } end
function Widget:SetBackdropBorderColor(...) self.borderColor = { ... } end
function Widget:SetStatusBarTexture(v) self.texture = v end
function Widget:SetMinMaxValues(a, b) self.min, self.max = a, b end
function Widget:SetValue(v) self.value = v end
function Widget:SetStatusBarColor(...) self.tint = { ... } end
function Widget:SetCooldown(a, b) self.cooldown = { a, b } end
CreateFrame = function(_, _, parent, template)
    local f = widget(parent)
    if template == 'ActionButtonSpellAlertTemplate' then
        local function animation() return { Play = function(self) self.playing = true end, Stop = function(self) self.playing = false end } end
        f.ProcStartAnim, f.ProcLoop = animation(), animation()
    end
    return f
end
LibStub = function() return { Fetch = function(_, kind, name) return kind .. '/' .. name end } end
C_Texture = { GetAtlasInfo = function() return true end }
GetTime = function() return 100 end
ns.SetFontFamily = function(t, path, size, flags) t.font = { path, size, flags } end
ns.GetFontPath = function(face) return face end
ns.ApplyShadow = function(t, cfg) t.shadow = cfg.enableShadow end
ns.BorderEdgeSize = function() return 16 end
ns.BORDER_COLOR = { r = 0.65, g = 0.49, b = 0.27, a = 1 }
ns.HEALTH_GREEN, ns.MANA_BLUE = { 0.15, 0.82, 0.15 }, { 0.18, 0.48, 1 }
ns.UnitFrames = { PALETTES = { flareui = { health = ns.HEALTH_GREEN, mana = ns.MANA_BLUE }, blizzard = { health = { 0, 1, 0 }, mana = { 0, 0, 1 } } } }
ns.CreateComboPoint = function(parent) return widget(parent) end
ns.SetComboPoint = function(p, n) p.value = n end
ns.AuraLook = { Style = function(b, look)
    b.look = look
    for _, key in ipairs({ 'Icon', 'Border', 'Count', 'Duration', 'PreviewTimer', 'Cooldown' }) do
        b['FlareUI_' .. key] = b['FlareUI_' .. key] or widget(b)
    end
end }
assert(loadfile('Settings/PreviewSamples.lua'))('FlareUI', ns)
local canvas = P.Create(widget(), 226, 226)
local cases = { 'uf.frameStyle', 'uf.palette', 'uf.simplePet', 'uf.hidePlayer', 'mm.style',
    'au.timer', 'uf.auraShape', 'ch.editBox', 'tt.healthBar', 'tt.ids', 'qt.wrap', 'qt.minimizeButton',
    'dm.pullLine', 'ab.buttonArt', 'ab.xpNumbers', 'rb.combo', 'rb.health', 'qol.bagGaps', 'qol.npLevel', 'rm.names' }
for _, key in ipairs(cases) do
    local spec = P.Resolve(row(key))
    assert(P.Show(canvas, spec), key)
    local before = allocated
    assert(P.Show(canvas, spec), key)
    assert(allocated == before, 'Repeated hover allocated widgets: ' .. key)
end
P.Show(canvas, P.Resolve(row('mm.style'), 'round'))
local before = allocated
P.Show(canvas, P.Resolve(row('mm.style'), 'round'))
assert(allocated == before)
P.Show(canvas, P.Resolve(row('au.timer')))
assert(canvas.frame.scripts.OnUpdate)
canvas.frame:Hide()
assert(canvas.frame.scripts.OnUpdate == nil, 'Hidden previews must stop updating')
P.Show(canvas, P.Resolve(row('au.timer')))
P.Show(canvas, nil)
assert(not canvas.frame.shown and canvas.frame.scripts.OnUpdate == nil)
values['chat.editBoxPosition'] = 'above'
P.Show(canvas, P.Resolve(row('ch.editBox')))
assert(canvas.objects.editBox.points[1][3] == -16, 'Input box above the chat')
values['chat.editBoxPosition'] = 'below'
P.Show(canvas, P.Resolve(row('ch.editBox')))
assert(canvas.objects.editBox.points[1][3] == -172, 'Input box below the chat')
values['chat.chatFont'] = { face = 'Fira Condensed', size = 19, flags = 'OUTLINE' }
P.Show(canvas, P.Resolve(font))
assert(canvas.objects.fontName.font[1] == 'Fira Condensed' and canvas.objects.fontName.font[2] == 19)
assert(canvas.frame.mouse == false)
print('PASS: all renderers, cached widgets, fonts, input placement and animation teardown')

local variants = {
    { 'uf.palette', 'unitframes.palette', { 'flareui', 'blizzard' } },
    { 'ch.editBox', 'chat.editBoxPosition', { 'inside', 'above', 'below' } },
    { 'tt.scale', 'tooltips.scale', { 0.5, 1, 1.5 } },
    { 'tt.anchor', 'tooltips.anchor', { 'default', 'cursorOffset' } },
    { 'qt.minimizeButton', 'objectivetracker.minimizeStyle', { 'button', 'header' } },
    { 'au.shape', 'auras.style', { 'round', 'square' } },
    { 'au.timer', 'auras.timer', { 'below', 'bottom', 'middle', 'none' } },
    { 'au.swipe', 'auras.swipe', { 'icon', 'border', 'both', 'none' } },
    { 'qol.bagColumns', 'tweaks.bagColumns', { 0, 6, 20 } },
    { 'dm.threatValue', 'damagemeter.threatValueDisplay', { 'both', 'percent', 'value' } },
    { 'rm.scale', 'radialmenu.scale', { 0.7, 1, 1.5 } },
    { 'rm.position', 'radialmenu.position', { 'cursor', 'center' } },
}
local toggles = {
    ['au.arrive'] = 'auras.arrive', ['au.skinCDM'] = 'auras.skinCDM', ['au.timerColor'] = 'auras.timerColor',
    ['ch.social'] = 'chat.socialHide', ['ch.channels'] = 'chat.channelHide', ['ch.menu'] = 'chat.menuHide',
    ['ch.volume'] = 'chat.showVolume', ['ch.copyButton'] = 'chat.copyButton', ['ch.combatLog'] = 'chat.hideCombatLog',
    ['ch.formatPlayer'] = 'chat.formatPlayer', ['ch.formatNPC'] = 'chat.formatNPC', ['ch.levels'] = 'chat.showLevel',
    ['tt.healthBar'] = 'tooltips.hideHealthBar', ['tt.borders'] = 'tooltips.borderByClass', ['tt.showGuild'] = 'tooltips.showGuild',
    ['tt.showGuildRank'] = 'tooltips.showGuildRank', ['tt.showTarget'] = 'tooltips.showTarget', ['tt.showThreat'] = 'tooltips.showThreat',
    ['qt.wrap'] = 'objectivetracker.wrapText', ['qt.zoneHeaders'] = 'objectivetracker.zoneHeaders',
    ['qt.focusButtons'] = 'objectivetracker.focusButtons', ['qt.playButtons'] = 'objectivetracker.playButtons',
    ['dm.pullLine'] = 'damagemeter.threatPullLine', ['dm.pullFlash'] = 'damagemeter.threatPullFlash',
    ['dm.tankLead'] = 'damagemeter.threatTankLead', ['dm.chatTab'] = 'damagemeter.chatTab',
    ['dm.combatTimer'] = 'damagemeter.combatTimer', ['dm.readyCheck'] = 'damagemeter.readyCheckButton', ['dm.countdown'] = 'damagemeter.countdownButton',
    ['ab.procGlow'] = 'actionbars.procGlow', ['ab.buttonArt'] = 'actionbars.buttonArt', ['ab.dimOnCooldown'] = 'actionbars.dimOnCooldown',
    ['ab.statusColours'] = 'actionbars.colors.enableRange', ['ab.gryphonsBehind'] = 'actionbars.gryphonsBehind', ['ab.hideGryphons'] = 'visibility.hideEndCaps',
    ['ab.xpQuest'] = 'actionbars.xpbar.questXP', ['qol.bagGaps'] = 'tweaks.bagGaps', ['qol.bagButtons'] = 'tweaks.bagButtons',
    ['qol.bagRarityBorders'] = 'tweaks.bagRarityBorders', ['qol.bagThickBorders'] = 'tweaks.bagThickBorders',
    ['qol.bagJunkIcon'] = 'tweaks.bagJunkIcon', ['qol.bagUpgradeArrow'] = 'tweaks.bagUpgradeArrow',
    ['qol.npCombo'] = 'tweaks.nameplateCombo', ['qol.npQuest'] = 'tweaks.nameplateQuest', ['qol.npNames'] = 'tweaks.nameplateHideNames',
    ['qol.npLevel'] = 'tweaks.nameplateHideLevel', ['qol.npLevelName'] = 'tweaks.nameplateLevelName', ['rm.names'] = 'radialmenu.showNames',
    ['mm.coordsHover'] = 'minimap.coordsOnHover',
}
for key, path in pairs(toggles) do variants[#variants + 1] = { key, path, { true, false } } end
local count = 0
for _, variant in ipairs(variants) do
    for _, value in ipairs(variant[3]) do
        values[variant[2]] = value
        assert(P.Show(canvas, P.Resolve(row(variant[1]))), variant[1])
        if canvas.frame.scripts.OnUpdate then canvas.frame.scripts.OnUpdate(canvas.frame, 0.5) end
        assert(values[variant[2]] == value, 'Preview changed saved setting: ' .. variant[2])
        count = count + 1
    end
end
values['unitframes.palette'] = 'blizzard'
P.Show(canvas, P.Resolve(row('uf.palette')))
assert(canvas.objects.paletteHealth.tint[1] == 0 and canvas.objects.paletteHealth.tint[2] == 1)
assert(canvas.objects.paletteMana.tint[3] == 1 and canvas.objects.paletteMana.tint[2] == 0)
values['tooltips.scale'] = 0.5
P.Show(canvas, P.Resolve(row('tt.scale')))
assert(canvas.tooltipCanvas.frame.scale == 1 / 3)
values['tooltips.scale'] = 1.5
P.Show(canvas, P.Resolve(row('tt.scale')))
assert(canvas.tooltipCanvas.frame.scale == 1)
values['radialmenu.scale'] = 1
P.Show(canvas, P.Resolve(row('rm.scale'))); local small = canvas.objects.art.width
values['radialmenu.scale'] = 1.5
P.Show(canvas, P.Resolve(row('rm.scale'))); assert(canvas.objects.art.width > small)
P.Show(canvas, P.Resolve(row('dm.pullFlash')))
P.Show(canvas, P.Resolve(row('ch.editBox')))
assert(canvas.frame.scripts.OnUpdate == nil, 'Changing preview must stop animation')
print('PASS: ' .. count .. ' setting variants, read-only rendering, production palettes and scale ranges')

values['actionbars.procGlow'] = true
P.Show(canvas, P.Resolve(row('ab.procGlow')))
canvas.objects.procGlow.ProcLoop:Play()
canvas.frame:Hide()
assert(not canvas.objects.procGlow.ProcStartAnim.playing and not canvas.objects.procGlow.ProcLoop.playing)
values['minimap.coordsOnHover'] = false
P.Show(canvas, P.Resolve(row('mm.coordsHover')))
assert(canvas.objects.coords.shown)
values['minimap.coordsOnHover'] = true
P.Show(canvas, P.Resolve(row('mm.coordsHover')))
assert(not canvas.objects.coords.shown)
values['tweaks.bagColumns'], values['tweaks.bagThickBorders'] = 20, true
P.Show(canvas, P.Resolve(row('qol.bagColumns')))
assert(canvas.objects.bagBorder1.backdrop.edgeSize <= canvas.objects.bagItem1.width / 2)
print('PASS: hidden proc loops, coordinate visibility and scaled bag borders')

for name, crop in pairs(P.ART) do
    local file = assert(io.open('Media/Art/Tour/' .. name .. '.png', 'rb'))
    local header = file:read(24); file:close()
    local function u32(at) local a,b,c,d = header:byte(at, at + 3); return ((a * 256 + b) * 256 + c) * 256 + d end
    assert(u32(17) == crop[3] and u32(21) == crop[4], 'Incorrect source crop: ' .. name)
    assert(crop[1] <= crop[3] and crop[2] <= crop[4])
end
C_Texture.GetAtlasInfo = function() return nil end
P.Show(canvas, P.Resolve(row('mm.style'), 'round'))
assert(canvas.objects.mapRing.texture == 'Interface\\Minimap\\UI-Minimap-Border')
print('PASS: shipped image dimensions/crops and missing-atlas fallback')

-- Exercise the real registry: card choices keep existing get/set, pending-reload and change events.
local real = { L = ns.L, Dialogs = {}, db = { profile = { unitframes = { enabled = true }, minimap = { enabled = true, style = 'square' } }, global = {} } }
local style = 'flareui'
real.UFRing = { Style = function() return style end, SetStyle = function(v) style = v end }
assert(loadfile('Settings/Copy.lua'))('FlareUI', real)
assert(loadfile('Settings/Registry.lua'))('FlareUI', real)
assert(loadfile('Settings/Fonts.lua'))('FlareUI', real)
assert(loadfile('Settings/Pages/UnitFrames.lua'))('FlareUI', real)
assert(loadfile('Settings/Pages/Minimap.lua'))('FlareUI', real)
local settings = real.Settings
local frameStyle, mapStyle = settings.rows['uf.frameStyle'], settings.rows['mm.style']
assert(frameStyle.kind == 'styles' and mapStyle.kind == 'styles')
assert(#frameStyle:Choices() == 3 and #mapStyle:Choices() == 2)
local changed
settings:On('RowChanged', function(r) changed = r.key end)
frameStyle:Set('forever')
assert(style == 'forever' and settings.pending['uf.frameStyle'] and changed == 'uf.frameStyle')
frameStyle:Set('flareui')
assert(not settings.pending['uf.frameStyle'])
mapStyle:Set('round')
assert(real.db.profile.minimap.style == 'round' and settings.pending['mm.style'])
mapStyle:Set('square')
assert(not settings.pending['mm.style'])
assert(settings.rows['uf.font.names.face'].previewFont == 'unitframes.font')
print('PASS: real registry integration, card choices, reload undo and font metadata')
