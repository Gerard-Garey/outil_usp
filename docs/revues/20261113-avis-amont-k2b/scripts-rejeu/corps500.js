const { chromium } = require('/opt/node-tools/node_modules/playwright');
(async () => { const b = await chromium.launch(); const p = await b.newPage();
  await p.goto('http://127.0.0.1:4322/', { waitUntil: 'networkidle' });
  const h = await p.$eval('#dl_donnees_xlsx', e => e.getAttribute('href'));
  const r = await p.request.get(new URL(h, 'http://127.0.0.1:4322/').href);
  console.log(r.status(), JSON.stringify(await r.text())); await b.close(); })();
