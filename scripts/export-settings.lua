local ns = { L = setmetatable({}, {__index=function(_,k)return k end}), Dialogs={}, db={profile={},global={}} }
local core=assert(io.open('../repo/Core.lua')):read('*a')
local chunk=core:match('(local VISIBILITY_KEYS.-)%-+%s*%-%- 5%. SHARED UTILITIES')
ns.defaults=assert(loadstring(chunk..' return defaults'))()
ns.db=ns.defaults
local fonts={'Friz Quadrata TT','Roboto Condensed','Fira Condensed','Cabin Condensed','Barlow Condensed','Asap Condensed'}
LibStub=function() return {List=function() return fonts end} end
ns.Conditions={BAR_TOKENS={},BAR_LEGACY={}}
Enum={}; CreateFrame=function() return {RegisterEvent=function()end, SetScript=function()end} end
_G.UIParent={}
assert(loadfile('../repo/Settings/Copy.lua'))('FlareUI',ns)
assert(loadfile('../repo/Settings/Registry.lua'))('FlareUI',ns)
assert(loadfile('../repo/Settings/Fonts.lua'))('FlareUI',ns)
local failures={}
for _,p in ipairs({'About','ActionBars','UnitFrames','ResourceBars','Chat','DamageMeter','Tooltips','Auras','Minimap','QuestTracker','RadialMenu','QualityOfLife','Advanced','Language'}) do
 local ok,err=pcall(function() assert(loadfile('../repo/Settings/Pages/'..p..'.lua'))('FlareUI',ns) end)
 if not ok then failures[#failures+1]=p..': '..tostring(err) end
end
local function str(s) return '"'..s:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n'):gsub('\r','\\r'):gsub('\t','\\t')..'"' end
local function json(v)
 local t=type(v)
 if t=='string' then return str(v) elseif t=='number' or t=='boolean' then return tostring(v) elseif t~='table' then return 'null' end
 local parts={};local array=#v>0
 if array then for _,x in ipairs(v)do parts[#parts+1]=json(x)end else for k,x in pairs(v)do if type(k)=='string' and type(x)~='function' then parts[#parts+1]=str(k)..':'..json(x)end end end
 return (array and '[' or '{')..table.concat(parts,',')..(array and ']' or '}')
end
local out={version='5.1.2',copy=ns.Copy,modules={},failures=failures}
for _,key in ipairs(ns.Settings.order) do
 local m=ns.Settings.modules[key]; local item={key=key,group=m.group,order=m.order,enabled=m.enabled,editMenuLabel=m.editMenuLabel,editTargets=m.editTargets,tabs={},rows={}}
 for _,tab in ipairs(m.tabs or {}) do item.tabs[#item.tabs+1]={key=tab.key,label=tab.label} end
 for _,section in ipairs(m.sections)do for _,r in ipairs(section.rows)do
  local row={label=r:Label(),desc=r:Description(),tip=r:Tip(),key=r.key,kind=r.kind,path=r.path,tab=r.tab,section=r.section,parent=r.parent,half=r.half,reload=r.reload,previewFont=r.previewFont}
  local okDefault,default=pcall(function()return r:ResetValue()end)
  if okDefault then row.default=default end
  local ok,choices=pcall(function()return r:Choices()end)
  if ok and choices and #choices>0 then row.choices=choices end
  item.rows[#item.rows+1]=row
 end end
 out.modules[#out.modules+1]=item
end
local f=assert(io.open('src/source-settings.json','w'));f:write(json(out));f:close()
print('Exported '..#out.modules..' modules; '..#failures..' load errors')
for _,err in ipairs(failures)do print(err)end
