// Mesure DOM sous media print, viewport = page A4 (portrait 794 x 1123 px, paysage 1123 x 794 px a 96 dpi), marges 10 mm = 38 px.
const { chromium } = require('/opt/node-tools/node_modules/playwright');
const methode = process.argv[2];
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1600, height: 1000 } });
  await page.goto('http://127.0.0.1:4321/', { waitUntil: 'networkidle' });
  await page.evaluate(m => { document.getElementById('methode').selectize.setValue(m); }, methode);
  await page.waitForTimeout(1500);
  if (methode === 'premium') { await page.evaluate(() => Shiny.setInputValue('nature_donnees', 'brutes')); await page.waitForTimeout(500); }
  await page.fill('#B', '99'); await page.waitForTimeout(500); await page.click('#go');
  await page.waitForSelector('a[data-value="Graphiques"]', { timeout: 180000 }); await page.waitForTimeout(3000);
  await page.click('a[data-value="Graphiques"]'); await page.waitForTimeout(3000);
  const sous = await page.$$eval('#onglets_graphiques a[data-toggle="tab"]', els => els.map(e => e.textContent.trim()));
  const sortie = [];
  for (const [nom, w, h] of [['portrait', 794, 1123], ['paysage', 1123, 794]]) {
    for (const bas of sous.concat(['(Calibration)'])) {
      await page.setViewportSize({ width: 1600, height: 1000 }); await page.emulateMedia({ media: null });
      if (bas === '(Calibration)') await page.click('a[data-value="Calibration"]'); else { await page.click('a[data-value="Graphiques"]'); await page.waitForTimeout(500); await page.click(`#onglets_graphiques a:text-is("${bas}")`); }
      await page.waitForTimeout(2000);
      await page.setViewportSize({ width: w, height: h }); await page.emulateMedia({ media: 'print' }); await page.waitForTimeout(1500);
      const m = await page.evaluate((limite) => [...document.querySelectorAll('.js-plotly-plot')].filter(e => e.offsetParent !== null).map(e => {
        const r = e.getBoundingClientRect(); const s = e.querySelector('svg.main-svg'); const rs = s ? s.getBoundingClientRect() : r;
        return { cadre_droite: Math.round(r.right), svg_droite: Math.round(rs.right), depasse: rs.right > limite + 1 }; }), w - 38);
      sortie.push({ methode, orientation: nom, onglet: bas, limite_px: w - 38, graphiques: m });
    }
  }
  await page.emulateMedia({ media: null });
  console.log(JSON.stringify(sortie));
  await browser.close();
})();
