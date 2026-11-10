import React,{useId} from 'react';
import {asset} from './PreviewParts';
// Source geometry: Settings/PreviewSamples.lua Unit and UnitFramesRing.lua PLATE/ART.
// Palette and border multipliers: UnitFrames.lua PALETTES and Core.lua BORDER_COLOR.
export function Unit({style='flareui',small=false,name='Aeloria',health=82,palette='flareui',pet=false,hostile=false,targetOf=false}){
 const id=useId().replace(/:/g,'');const plate=style==='forever',plain=style==='addon',right=targetOf||hostile;const W=plate?194:plain?240:280,H=plate?68:plain?70:100;
 const bx=plate?(right?4:69):plain?4:right?4:70,by=plate?29:plain?5:24,bw=plate?121:plain?232:200,bh=plate?13:plain&&targetOf?56:44,ph=plain&&targetOf?0:plate?8:12,py=plate?45:by+bh+1;
 const d=plate?62:80,px=plate?(right?128:4):(right?200:0),pyFace=plate?2:10;
 const rgb=hostile?(palette==='blizzard'?[1,0,0]:[.87,.27,.27]):pet?(palette==='blizzard'?[0,1,0]:[.15,.82,.15]):[.53,.53,.93];
 const mana=pet?[1,.5,.25]:palette==='blizzard'?[0,0,1]:[.18,.48,1];
 const filter=(key,c)=><filter id={`${id}-${key}`} colorInterpolationFilters="sRGB"><feComponentTransfer><feFuncR type="linear" slope={c[0]}/><feFuncG type="linear" slope={c[1]}/><feFuncB type="linear" slope={c[2]}/></feComponentTransfer></filter>;
 const bar=(key,y,h,fill,texture)=><g data-bar={key}><rect x={bx} y={y} width={bw} height={h} fill="#080b10"/><svg x={bx} y={y} width={bw*fill} height={h} viewBox={`0 0 ${256*fill} 32`} preserveAspectRatio="none"><image href={asset(`frames/${texture}.png`)} width="256" height="32" filter={`url(#${id}-${key})`}/></svg></g>;
 const frame=(x,y,w,h)=><path d={`M${x+3} ${y}H${x+w-3}l3 3v${h-6}l-3 3H${x+3}l-3-3V${y+3}z`} fill="#11110e" stroke="#a67d45" strokeWidth={plate?1.2:1.6}/>;
 return <div className={`unit-sample unit-renderer ${style} ${small?'small':''} palette-${palette}`} data-unit={pet?'pet':targetOf?'targettarget':hostile?'target':'player'} data-style={style} data-side={right?'right':'left'} data-power={ph>0}>
 <svg className="unit-vector" viewBox={`0 0 ${W} ${H}`} role="img" aria-label={`${name}, ${style} frame`}>
 <defs>{filter('health',rgb)}{filter('power',mana)}<clipPath id={`${id}-rim`}><circle cx={px+d/2} cy={pyFace+d/2} r={d/2}/></clipPath><clipPath id={`${id}-face`}><circle cx={px+d/2} cy={pyFace+d/2} r={d*.43}/></clipPath><linearGradient id={`${id}-metal`} x2=".8" y2="1"><stop stopColor="#f1d498"/><stop offset=".3" stopColor="#a37a37"/><stop offset=".6" stopColor="#60441d"/><stop offset=".85" stopColor="#d0a35d"/><stop offset="1" stopColor="#66502d"/></linearGradient></defs>
 {plate?<>{frame(bx-3,8,bw+6,49)}{frame(bx-1,11,bw+2,15)}{frame(bx-1,28,bw+2,15)}{frame(bx-1,44,bw+2,10)}</>:frame(bx-3,by-3,bw+6,bh+ph+7)}
 {bar('health',by,bh,health/100,plate?'health':palette==='blizzard'?'bright':'flat')}{ph>0&&bar('power',py,ph,.65,plate?'power':palette==='blizzard'?'bright':'flat')}
 {!plain&&<><circle cx={px+d/2} cy={pyFace+d/2} r={d*.43} fill="#000"/><image href={asset(pet?'ability_hunter_pet_wolf.jpg':plate?'frames/class-warlock.jpg':'frames/portrait-undead.png')} x={px+d*.07} y={pyFace+d*.07} width={d*.86} height={d*.86} preserveAspectRatio="xMidYMid slice" clipPath={`url(#${id}-face)`}/><g clipPath={`url(#${id}-rim)`}><svg x={px} y={pyFace} width={d} height={d} viewBox="252.78 1.67 122.22 122.22" overflow="hidden"><image href={asset('frames/unit-atlas.png')} width="1024" height="512"/></svg></g><circle cx={px+d/2} cy={pyFace+d/2} r={d*.475} fill="none" stroke={`url(#${id}-metal)`} strokeWidth={d*.025}/></>}
 <g fill="#f3f0dd" fontFamily="Georgia,serif" paintOrder="stroke" stroke="#111" strokeWidth="1.5" strokeLinejoin="round"><text x={plate?bx+bw/2:bx+6} y={plate?21:by+16} fontSize={plate?8.3:plain&&targetOf?15:12} textAnchor={plate?'middle':'start'}>{name.length>18?name.slice(0,17)+'…':name}</text>{!targetOf&&<text x={plate?bx+bw/2:bx+bw-5} y={by+(plate?10:16)} fontSize={plate?9:12} textAnchor={plate?'middle':'end'}>{health}%</text>}{ph>0&&<text x={plate?bx+bw/2:bx+bw-5} y={py+ph-2} fontSize={plate?7:10} textAnchor={plate?'middle':'end'}>65</text>}</g>
 {!plain&&!pet&&!targetOf&&<g><circle cx={right?W-12:12} cy={plate?58:84} r={plate?10:14} fill="#090909" stroke={`url(#${id}-metal)`} strokeWidth="2"/><text x={right?W-12:12} y={plate?61:88} textAnchor="middle" fill="#e7dac1" fontFamily="Georgia" fontSize={plate?8:11}>60</text></g>}
 </svg></div>
}
