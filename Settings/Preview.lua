local ADDON_NAME, ns = ...
local S, L = ns.Settings, ns.L

-- A visual companion to the row's explanation. These are ordinary, mouse-free frames with sample
-- data: no unit buttons, saved-variable writes, live-frame reparenting or protected templates.
local P = { renderers = {} }
ns.SettingsPreview = P
local MEDIA = 'Interface\\AddOns\\' .. ADDON_NAME .. '\\Media\\'
P.MEDIA = MEDIA
P.ART = {
    StyleFlareUI = { 432, 160, 512, 256 }, StyleForever = { 480, 155, 512, 256 },
    StyleAddon = { 355, 100, 512, 128 }, ActionBars = { 920, 195, 1024, 256 },
    Chat = { 420, 205, 512, 256 }, Meter = { 425, 205, 512, 256 },
    Minimap = { 280, 285, 512, 512 }, Quests = { 240, 335, 256, 512 }, Radial = { 500, 500, 512, 512 },
}
P.styles = { flareui = 'StyleFlareUI', forever = 'StyleForever', addon = 'StyleAddon' }

local routes = {}
local function Route(kind, prefix, keys)
    for key in keys:gmatch('%S+') do routes[prefix .. '.' .. key] = kind end
end
Route('unit', 'uf', 'frameStyle palette fullNames simplePet simpleTargetOf hidePlayer')
Route('unitAuras', 'uf', 'auraShape auraSwipe auraTimer auraTimerColor')
Route('auras', 'au', 'shape swipe timer timerColor arrive skinCDM')
Route('minimap', 'mm', 'style bag clockStats microMenu coordsHover')
Route('chat', 'ch', 'opacity border editBoxOpacity editBox lineHeight formatNPC formatPlayer timestamps shortChannels levels social channels menu volume copyButton combatLog minAlpha')
Route('tooltip', 'tt', 'scale anchor healthBar borders classNames showThreat showTarget showGuild showGuildRank hideFaction shortItemStats ids')
Route('tracker', 'qt', 'opacity border zoneHeaders tags wrap count hideLevel focusButtons playButtons minimizeButton')
Route('meter', 'dm', 'opacity border minAlpha chatTab combatTimer readyCheck countdown threatValue pullLine pullFlash tankLead')
Route('actions', 'ab', 'statusColours procGlow gryphonsBehind hideMacroText hideKeybinds cleanKeybinds buttonArt dimOnCooldown hideGryphons')
Route('xp', 'ab', 'xpBar xpText xpNumbers xpQuest')
Route('resources', 'rb', 'health power mana combo swingMain swingOff swingRanged')
Route('bags', 'qol', 'bagColumns bagGaps bagButtons bagRarityBorders bagThickBorders bagJunkIcon bagUpgradeArrow')
Route('nameplate', 'qol', 'npCombo npQuest npNames npLevel npLevelName')
Route('radial', 'rm', 'scale names position')

function P.Resolve(row, value)
    if not row then return nil end
    if row.previewFont then return { kind = 'font', font = row.previewFont, key = row.key } end
    local kind = routes[row.key]
    if not kind then return nil end
    if value == nil then value = row:Get() end
    return { kind = kind, key = row.key, value = value }
end

-- Cached by the owning canvas, so moving between controls never leaks anonymous WoW frames.
local Canvas = {}
Canvas.__index = Canvas
function Canvas:Reset()
    self.frame:SetScript('OnUpdate', nil)
    for _, object in pairs(self.objects) do
        if object.ProcStartAnim then object.ProcStartAnim:Stop() end
        if object.ProcLoop then object.ProcLoop:Stop() end
        object:Hide()
    end
end
function Canvas:Object(id, kind, template)
    local object = self.objects[id]
    if not object then
        if kind == 'Texture' then object = self.frame:CreateTexture(nil, 'ARTWORK')
        elseif kind == 'OverlayTexture' then object = self.overlay:CreateTexture(nil, 'OVERLAY')
        elseif kind == 'FontString' then object = self.overlay:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        else object = CreateFrame(kind or 'Frame', nil, self.frame, template) end
        self.objects[id] = object
    end
    object:ClearAllPoints()
    object:SetAlpha(1)
    object:Show()
    return object
end
function Canvas:Text(id, text, x, y, width, font)
    local t = self:Object(id, 'FontString')
    t:SetPoint('TOPLEFT', x, -y)
    t:SetWidth(width or self.width - x - 8)
    t:SetJustifyH('LEFT')
    t:SetWordWrap(true)
    t:SetTextColor(0.9, 0.9, 0.9, 1)
    local cfg = font or {}
    ns.SetFontFamily(t, ns.GetFontPath(cfg.face or 'Friz Quadrata TT'), math.max(8, cfg.size or 11), cfg.flags == 'NONE' and '' or cfg.flags or '')
    ns.ApplyShadow(t, cfg)
    t:SetText(text)
    return t
end
function Canvas:Texture(id, path, x, y, w, h, overlay)
    local t = self:Object(id, overlay and 'OverlayTexture' or 'Texture')
    t:SetPoint('TOPLEFT', x, -y)
    t:SetSize(w, h)
    t:SetTexture(path)
    t:SetTexCoord(0, 1, 0, 1)
    t:SetVertexColor(1, 1, 1, 1)
    t:SetDesaturated(false)
    return t
end
function Canvas:Art(name, x, y, w, h, id)
    local a = P.ART[name]
    local scale = math.min(w / a[1], h / a[2])
    local tw, th = a[1] * scale, a[2] * scale
    local t = self:Texture(id or 'art', MEDIA .. 'Art\\Tour\\' .. name .. '.png', x + (w - tw) / 2, y + (h - th) / 2, tw, th)
    t:SetTexCoord(0, a[1] / a[3], 0, a[2] / a[4])
    return t
end
function Canvas:Box(id, x, y, w, h, border, opacity)
    local f = self:Object(id, 'Frame', 'BackdropTemplate')
    f:SetPoint('TOPLEFT', x, -y)
    f:SetSize(w, h)
    local lsm = LibStub('LibSharedMedia-3.0')
    local edge = border and border ~= 'None' and lsm:Fetch('border', border) or nil
    f:SetBackdrop({ bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background', edgeFile = edge,
        tile = true, tileSize = 16, edgeSize = edge and ns.BorderEdgeSize(edge, 16) or nil,
        insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    f:SetBackdropColor(1, 1, 1, opacity or 0)
    local c = ns.BORDER_COLOR
    f:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
    -- Labels/textures on the canvas must stay above the sample background.
    f:SetFrameLevel(self.frame:GetFrameLevel())
    return f
end
function Canvas:Bar(id, x, y, w, h, fraction, color, texture)
    local bar = self:Object(id, 'StatusBar')
    bar:SetPoint('TOPLEFT', x, -y)
    bar:SetSize(w, h)
    bar:SetStatusBarTexture(LibStub('LibSharedMedia-3.0'):Fetch('statusbar', texture or 'FlareUI Flat'))
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(fraction)
    bar:SetStatusBarColor(unpack(color))
    bar:SetFrameLevel(self.frame:GetFrameLevel())
    return bar
end
function P.Create(parent, width, height)
    local f = CreateFrame('Frame', nil, parent)
    f:SetSize(width, height)
    f:EnableMouse(false)
    local canvas = setmetatable({ frame = f, width = width, height = height, objects = {} }, Canvas)
    canvas.overlay = CreateFrame('Frame', nil, f)
    canvas.overlay:SetAllPoints()
    canvas.overlay:SetFrameLevel(f:GetFrameLevel() + 20)
    f:SetScript('OnHide', function() canvas:Reset() end)
    return canvas
end
function P.Show(canvas, spec)
    canvas:Reset()
    canvas.frame:SetAlpha(1)
    local draw = spec and P.renderers[spec.kind]
    if not draw then canvas.frame:Hide() return false end
    canvas.frame:Show()
    draw(canvas, spec)
    return true
end

-- Images and the map specimen are shared between cards and the large Info Panel.
function P.Style(canvas, row, value)
    return P.Show(canvas, P.Resolve(row, value))
end
