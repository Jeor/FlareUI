import {chromium,expect} from '@playwright/test';
import {mkdir,writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'chrome',headless:true});
const page=await browser.newPage({viewport:{width:1440,height:1000},deviceScaleFactor:1});
const errors=[];page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
try{
await page.goto(process.env.TEST_URL||'http://127.0.0.1:5173');await page.evaluate(()=>localStorage.clear());await page.reload();
await expect(page.getByRole('heading',{name:'Unit Frames',exact:true,level:1})).toBeVisible();
await page.evaluate(()=>document.fonts.ready);
await mkdir('test-results/screenshots',{recursive:true});
await page.screenshot({path:'test-results/screenshots/proposed-desktop.png',fullPage:true});
await expect(page.getByText('Design notes',{exact:true})).toHaveCount(0);
await page.getByRole('button',{name:'Current layout',exact:true}).click();
await expect(page.locator('.lab')).toHaveClass(/current/);
await page.getByRole('button',{name:'Design proposal',exact:true}).click();
await page.getByRole('tab',{name:'Frames',exact:true}).click();
await expect(page.locator('.frame-card')).toHaveCount(7);
const raid=page.getByRole('button',{name:'Raid Frames',exact:true});await expect(raid).toHaveAttribute('aria-pressed','true');await raid.click();await expect(raid).toHaveAttribute('aria-pressed','false');await expect(page.getByText('1 change would require a reload',{exact:false})).toBeVisible();await raid.click();await expect(page.getByRole('button',{name:'Simulate reload'})).toBeDisabled();
await page.screenshot({path:'test-results/screenshots/frame-cards.png',fullPage:true});
await page.getByRole('navigation').getByRole('button',{name:'Quest Tracker'}).click();
await page.getByRole('button',{name:'Border',exact:true}).click();
await page.getByRole('option',{name:'None',exact:true}).hover();
await expect(page.locator('.tracker-preview')).toHaveClass(/no-border/);
await expect(page.getByRole('button',{name:'Border',exact:true})).toContainText('FlareUI Frames');
await page.getByRole('option',{name:'None',exact:true}).click();await expect(page.getByRole('button',{name:'Border',exact:true})).toContainText('None');
await page.reload();await page.getByRole('navigation').getByRole('button',{name:'Quest Tracker'}).click();await expect(page.getByRole('button',{name:'Border',exact:true})).toContainText('None');
await page.getByRole('tab',{name:'Fonts',exact:true}).click();await page.locator('.font-heading').first().click();await page.locator('.select-button').first().click();await page.getByRole('option',{name:'Roboto Condensed',exact:true}).hover();await expect(page.getByRole('option',{name:'Roboto Condensed',exact:true})).toHaveCSS('font-family','"Roboto Condensed"');await page.keyboard.press('Escape');
await page.getByRole('textbox',{name:'Search settings'}).fill('combo');await expect(page.getByRole('heading',{name:'Search results'})).toBeVisible();await expect(page.locator('.setting-row').first()).toBeVisible();await page.getByRole('button',{name:'Clear search'}).click();
for(const title of ['Action Bars','Resource Bars','Buffs & Debuffs','Minimap','Chat','Damage Meter','Quest Tracker','Tooltips','Quality of Life','Radial Menu','Profiles','Language','About','Unit Frames']){await page.getByRole('navigation').getByRole('button',{name:title,exact:false}).click();await expect(page.getByRole('heading',{name:title,level:1,exact:true})).toBeVisible()}
await page.getByRole('button',{name:'Reset sample',exact:true}).click();await expect(page.getByRole('dialog')).toBeVisible();await page.getByRole('button',{name:'Cancel',exact:true}).click();
await page.setViewportSize({width:390,height:844});await page.screenshot({path:'test-results/screenshots/proposed-mobile.png',fullPage:true});
const sizes=await page.evaluate(()=>({viewport:innerWidth,body:document.documentElement.scrollWidth}));if(sizes.body>sizes.viewport+1)throw Error('Mobile overflow: '+JSON.stringify(sizes));
if(errors.length)throw Error(errors.join('\n'));
const report={status:'passed',desktop:'1440 × 1000',mobile:'390 × 844',flows:['14 sections','layout comparison without review links','7 frame cards','toggle/undo reload state','dropdown hover without committing','dropdown selection','local persistence','font menu rendering','search','dialog','mobile overflow'],consoleErrors:errors};await writeFile('test-results/browser-test-results.json',JSON.stringify(report,null,2));console.log(JSON.stringify(report,null,2));
}finally{await browser.close()}

