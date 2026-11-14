const { chromium } = require('/opt/node-tools/node_modules/playwright');
const URL = 'http://127.0.0.1:' + process.env.PORT_APP + '/';
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1600, height: 1000 } });
  await page.goto(URL, { waitUntil: 'networkidle' });
  await page.fill('#B', '99'); await page.waitForTimeout(500);
  await page.click('#go');
  await page.waitForSelector('a[data-value="Graphiques"]', { timeout: 180000 });
  await page.waitForTimeout(3000);
  const liens = await page.$$eval('a.shiny-download-link', els => els.map(e => ({ id: e.id, href: e.getAttribute('href'), visible: e.offsetParent !== null })));
  console.log('liens de telechargement:', JSON.stringify(liens));
  for (const l of liens) {
    const r = await page.request.get(new URL_(l.href).href).catch(e => ({ erreur: String(e) }));
    if (r.erreur) { console.log(l.id, 'ERREUR requete', r.erreur); continue; }
    const corps = (await r.body()).length;
    console.log(l.id, 'statut HTTP', r.status(), 'octets', corps, 'content-type', r.headers()['content-type'], r.status() >= 400 ? 'CORPS: ' + JSON.stringify((await r.text())) : '');
  }
  function URL_(h) { return new globalThis.URL(h, URL); }
  // Clic reel sur chaque lien (evenement 'download') et notification a l'ecran
  for (const l of liens) {
    await page.click('a[data-value="Donnees"]').catch(() => {});
    const el = await page.$('#' + l.id);
    if (!el) continue;
    // rendre visible l'onglet qui porte le lien
    const ok = await Promise.race([
      page.waitForEvent('download', { timeout: 8000 }).then(d => 'download: ' + d.suggestedFilename()).catch(() => 'aucun evenement download'),
      el.evaluate(e => e.click()).then(() => new Promise(r => setTimeout(() => r(null), 8500)))
    ]);
    const notifs = await page.$$eval('.shiny-notification', els => els.map(e => e.textContent.trim()));
    console.log('clic', l.id, '->', ok, '| notifications a l\'ecran :', JSON.stringify(notifs));
  }
  await browser.close();
})();
