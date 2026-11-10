import data from './source-settings.json';
export const clean=s=>String(s??'').replace(/\|c[\da-f]{8}|\|r/gi,'').replace(/\|[TA].*?\|[ta]/g,'').replace(/\{Module\}/g,'This module');
export const order=['about','adv','language','ab','uf','rb','au','mm','ch','dm','qt','tt','qol','rm'];
export const modules=order.map(k=>data.modules.find(m=>m.key===k)).filter(Boolean).map(m=>({...m,title:clean(data.copy.modules[m.key]?.title||m.key),desc:clean(data.copy.modules[m.key]?.desc),tabs:Array.isArray(m.tabs)?m.tabs.map((t,i)=>({...t,label:t.label||data.copy.modules[m.key]?.tabs?.[i]||t.key})):[],rows:m.rows.map(r=>({...r,label:clean(r.label||data.copy.rows[r.key]?.label||r.key.split('.').pop()),desc:clean(r.desc||data.copy.rows[r.key]?.desc),tip:clean(r.tip),choices:Array.isArray(r.choices)?r.choices.filter(c=>!c.divider):[],sectionLabel:clean(data.copy.sections[r.section]||'Appearance')}))}));
export const allRows=modules.flatMap(m=>m.rows.map(r=>({...r,module:m.key,moduleTitle:m.title})));
export const fontNames=['Friz Quadrata TT','Roboto Condensed','Fira Condensed','Cabin Condensed','Barlow Condensed','Asap Condensed'];
export const fontFamily=f=>({'Friz Quadrata TT':'Georgia','Fira Condensed':'Fira Condensed'}[f]||f||'Georgia');
export const defaults=Object.fromEntries(allRows.map(r=>[r.key,r.default??(r.key.endsWith('.face')?'Friz Quadrata TT':r.key.endsWith('.size')?12:r.choices[0]?.value??false)]));
export function loadState(){try{const saved=JSON.parse(localStorage.getItem('flareui-lab-values')||'{}');return Object.fromEntries(allRows.map(r=>[r.key,saved[r.key]??defaults[r.key]]))}catch{return {...defaults}}}
