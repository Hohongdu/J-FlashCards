import fs from 'node:fs/promises';
import path from 'node:path';
import { chromium } from 'playwright';

const OUT_DIR = path.resolve('Data', 'jlptcode');

async function ensureDir(p) {
  await fs.mkdir(p, { recursive: true });
}

/**
 * jlptcode word API:
 * - level: "1".."5" where 1=N1, 5=N5
 */
async function scrapeWordsForLevel(page, levelNumber) {
  const searchInfo = {
    type: 'jlpt',
    level: String(levelNumber),
    wordType: '1',
    parts: [],
    wordShowType: '1',
  };

  const pageInfoResp = await page.request.post('https://www.jlptcode.com/api/word/page', {
    data: { searchInfo, pageInfo: { total: 0, totalPage: 0, currentPage: 1, startPage: 1, pageSize: 10 } },
  });
  if (!pageInfoResp.ok()) throw new Error(`word/page failed for level ${levelNumber}: ${pageInfoResp.status()}`);
  const pageInfo = await pageInfoResp.json();

  const totalPage = Number(pageInfo.totalPage || 0);
  const pageSize = 100;

  const all = [];
  for (let currentPage = 1; currentPage <= totalPage; currentPage++) {
    const resp = await page.request.post('https://www.jlptcode.com/api/word/list', {
      data: {
        searchInfo,
        pageInfo: {
          total: pageInfo.total,
          totalPage: pageInfo.totalPage,
          currentPage,
          startPage: pageInfo.startPage,
          pageSize,
        },
      },
    });
    if (!resp.ok()) throw new Error(`word/list failed for level ${levelNumber} page ${currentPage}: ${resp.status()}`);

    const list = await resp.json();
    if (!Array.isArray(list)) throw new Error(`word/list unexpected response for level ${levelNumber} page ${currentPage}`);

    all.push(...list);
    await page.waitForTimeout(150);
  }

  return { pageInfo, words: all };
}

async function scrapeGrammarForLevel(page, jlptLevel) {
  const resp = await page.request.post('https://www.jlptcode.com/api/levelUp/list', {
    data: { params: { level: jlptLevel, classification: 'grammar' } },
  });
  if (!resp.ok()) throw new Error(`levelUp/list failed for ${jlptLevel}: ${resp.status()}`);
  const list = await resp.json();
  if (!Array.isArray(list)) throw new Error(`levelUp/list unexpected response for ${jlptLevel}`);
  return list;
}

function toJlptLevel(levelNumber) {
  // 1 -> N1, 2 -> N2, ...
  return `N${levelNumber}`;
}

async function main() {
  await ensureDir(OUT_DIR);

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Prime cookies/session
  await page.goto('https://www.jlptcode.com/word/jlpt', { waitUntil: 'domcontentloaded' });

  // Scrape words N5->N1 (level 5 down to 1)
  for (const levelNumber of [5, 4, 3, 2, 1]) {
    const jlptLevelLabel = toJlptLevel(levelNumber);
    console.log(`Scraping words for ${jlptLevelLabel}...`);
    const data = await scrapeWordsForLevel(page, levelNumber);
    const outPath = path.join(OUT_DIR, `${jlptLevelLabel.toLowerCase()}_words.json`);
    await fs.writeFile(outPath, JSON.stringify(data, null, 2), 'utf8');
    console.log(`  wrote ${outPath} (words: ${data.words.length})`);
  }

  // Prime for levelUp
  await page.goto('https://www.jlptcode.com/levelUp?level=N5', { waitUntil: 'domcontentloaded' });

  // Scrape grammar lists N5->N1
  for (const levelNumber of [5, 4, 3, 2, 1]) {
    const jlptLevelLabel = toJlptLevel(levelNumber);
    console.log(`Scraping grammar for ${jlptLevelLabel}...`);
    const list = await scrapeGrammarForLevel(page, jlptLevelLabel);
    const outPath = path.join(OUT_DIR, `${jlptLevelLabel.toLowerCase()}_grammar.json`);
    await fs.writeFile(outPath, JSON.stringify(list, null, 2), 'utf8');
    console.log(`  wrote ${outPath} (items: ${list.length})`);
    await page.waitForTimeout(150);
  }

  await browser.close();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
