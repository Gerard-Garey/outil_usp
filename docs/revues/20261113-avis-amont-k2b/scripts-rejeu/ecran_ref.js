const { chromium } = require('/opt/node-tools/node_modules/playwright');
(async () => {
  const browser = await chromium.launch(); const out = {};
  for (const w of [960, 1600]) {
    const page = await browser.newPage({ viewport: { width: w, height: 1000 } });
    await page.goto('http://127.0.0.1:4321/', { waitUntil: 'networkidle' });
    await page.evaluate(() => Shiny.setInputValue('nature_donnees', 'brutes')); await page.waitForTimeout(500);
    await page.fill('#B', '99'); await page.waitForTimeout(500); await page.click('#go');
    await page.waitForSelector('a[data-value="Graphiques"]', { timeout: 180000 }); await page.waitForTimeout(3000);
    await page.click('a[data-value="Graphiques"]'); await page.waitForTimeout(3000);
    const sous = await page.$$eval('#onglets_graphiques a[data-toggle="tab"]', els => els.map(e => e.textContent.trim()));
    out[w] = {};
    for (const bas of sous) { await page.click(`#onglets_graphiques a:text-is("${bas}")`); await page.waitForTimeout(2000);
      out[w][bas] = await page.evaluate(() => [...document.querySelectorAll('.js-plotly-plot')].filter(e => e.offsetParent !== null).map(e => Math.round(e.getBoundingClientRect().width)));
    }
    await page.close();
  }
  console.log(JSON.stringify(out)); await browser.close();
})();
