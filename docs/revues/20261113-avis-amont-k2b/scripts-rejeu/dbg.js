const { chromium } = require('/opt/node-tools/node_modules/playwright');
(async () => { const b = await chromium.launch(); const p = await b.newPage({ viewport: { width: 1600, height: 1000 } });
  await p.goto('http://127.0.0.1:4321/', { waitUntil: 'networkidle' });
  await p.fill('#B', '99'); await p.waitForTimeout(500); await p.click('#go'); await p.waitForTimeout(15000);
  console.log(JSON.stringify(await p.$$eval('.shiny-notification', e => e.map(x => x.textContent.trim()))));
  console.log(JSON.stringify(await p.$$eval('.err, .warn', e => e.map(x => x.textContent.trim().slice(0, 300)))));
  await p.screenshot({ path: 'dbg.png' }); await b.close(); })();
