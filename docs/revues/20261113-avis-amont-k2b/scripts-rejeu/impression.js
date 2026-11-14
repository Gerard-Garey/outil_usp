// Rendu reel de l'impression des onglets a graphiques plotly (#566). Usage : node impression.js <methode> <dossier_sortie>
const { chromium } = require('/opt/node-tools/node_modules/playwright');
const methode = process.argv[2], out = process.argv[3];
const URL = 'http://127.0.0.1:' + (process.env.PORT_APP || '4321') + '/';
(async () => {
  const browser = await chromium.launch({ executablePath: process.env.CHROME || undefined });
  const page = await browser.newPage({ viewport: { width: 1600, height: 1000 } });
  await page.goto(URL, { waitUntil: 'networkidle' });
  await page.evaluate(m => { document.getElementById('methode').selectize.setValue(m); }, methode);
  await page.waitForTimeout(1500);
  if (methode === 'premium') { await page.evaluate(() => Shiny.setInputValue('nature_donnees', 'brutes')); await page.waitForTimeout(500); }
  await page.fill('#B', '99');
  await page.waitForTimeout(500);
  await page.click('#go');
  await page.waitForSelector('a[data-value="Graphiques"]', { timeout: 120000 });
  await page.waitForTimeout(4000);
  const resultats = [];
  const mesure = async (etiquette, mediaOrient) => {
    // largeur utile A4 : 210 mm - 2 x 10 mm = 190 mm = 718 px ; paysage 277 mm = 1047 px
    await page.emulateMedia({ media: 'print' });
    const m = await page.evaluate(() => {
      const vis = [...document.querySelectorAll('.js-plotly-plot')].filter(e => e.offsetParent !== null);
      return vis.map(e => { const r = e.getBoundingClientRect(); const s = e.querySelector('svg.main-svg'); const rs = s ? s.getBoundingClientRect() : null;
        return { id: e.parentElement && e.parentElement.id, x: Math.round(r.left), w: Math.round(r.width), droite: Math.round(r.right), svgw: rs ? Math.round(rs.width) : null }; });
    });
    await page.emulateMedia({ media: null });
    return m;
  };
  const onglets = async () => page.$$eval('#onglets_graphiques a[data-toggle="tab"], #onglets_graphiques a[data-bs-toggle="tab"]', els => els.map(e => e.textContent.trim()));
  await page.click('a[data-value="Graphiques"]');
  await page.waitForTimeout(3000);
  const liste = await onglets();
  const sous = liste.length ? liste : [];
  const toutes = sous.map(t => ['Graphiques', t]).concat([['Calibration', null]]);
  for (const [haut, bas] of toutes) {
    await page.click(`a[data-value="${haut}"]`);
    await page.waitForTimeout(800);
    if (bas) { await page.click(`#onglets_graphiques a:text-is("${bas}")`); await page.waitForTimeout(2500); }
    const nom = (haut + '_' + (bas || '')).replace(/[^A-Za-z0-9]+/g, '_');
    for (const paysage of [false, true]) {
      const fichier = `${out}/${methode}_${nom}_${paysage ? 'paysage' : 'portrait'}.pdf`;
      await page.pdf({ path: fichier, format: 'A4', landscape: paysage, printBackground: true });
    }
    // largeur du conteneur sous media print, a la largeur de la fenetre de la page (1600 px, ecran)
    resultats.push({ onglet: nom, graphiques_ecran: await page.evaluate(() => [...document.querySelectorAll('.js-plotly-plot')].filter(e => e.offsetParent !== null).map(e => Math.round(e.getBoundingClientRect().width))) });
  }
  console.log(JSON.stringify({ methode, onglets: liste, resultats }, null, 1));
  await browser.close();
})();
