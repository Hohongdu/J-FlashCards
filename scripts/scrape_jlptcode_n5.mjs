import fs from 'node:fs/promises';
import path from 'node:path';
import { chromium } from 'playwright';

const OUT_DIR = path.resolve('Data', 'jlptcode');
const WORDS_PATH = path.join(OUT_DIR, 'n5_words.json');
const GRAMMAR_PATH = path.join(OUT_DIR, 'n5_grammar.json');

async function ensureDir(p) {
  await fs.mkdir(p, { recursive: true });
}

async function scrapeN5Words(page) {
  // JLPTCODE uses level: "1".."5" where 1=N1, 5=N5
  const searchInfo = { type: 'jlpt', level: '5', wordType: '1', parts: [], wordShowType: '1' };

  // First fetch page info (total, totalPage)
  const pageInfoResp = await page.request.post('https://www.jlptcode.com/api/word/page', {
    data: { searchInfo, pageInfo: { total: 0, totalPage: 0, currentPage: 1, startPage: 1, pageSize: 10 } },
  });
  if (!pageInfoResp.ok()) throw new Error(`word/page failed: ${pageInfoResp.status()}`);
  const pageInfo = await pageInfoResp.json();

  const pageSize = 100; // try bigger pages to reduce calls
  const totalPage = Number(pageInfo.totalPage || 0);

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
    if (!resp.ok()) throw new Error(`word/list failed on page ${currentPage}: ${resp.status()}`);
    const list = await resp.json();
    if (!Array.isArray(list)) throw new Error(`word/list unexpected response on page ${currentPage}`);

    all.push(...list);

    // Basic politeness delay
    await page.waitForTimeout(150);
  }

  return { pageInfo, words: all };
}

async function scrapeN5Grammar(page) {
  // LevelUp grammar endpoint returns question objects
  const resp = await page.request.post('https://www.jlptcode.com/api/levelUp/list', {
    data: { params: { level: 'N5', classification: 'grammar' } },
  });
  if (!resp.ok()) throw new Error(`levelUp/list failed: ${resp.status()}`);
  const list = await resp.json();
  if (!Array.isArray(list)) throw new Error('levelUp/list unexpected response');
  return list;
}

async function main() {
  await ensureDir(OUT_DIR);

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Prime cookies/session by visiting the site once
  await page.goto('https://www.jlptcode.com/word/jlpt', { waitUntil: 'domcontentloaded' });

  const wordData = await scrapeN5Words(page);

  await page.goto('https://www.jlptcode.com/levelUp?level=N5', { waitUntil: 'domcontentloaded' });
  const grammarData = await scrapeN5Grammar(page);

  await fs.writeFile(WORDS_PATH, JSON.stringify(wordData, null, 2), 'utf8');
  await fs.writeFile(GRAMMAR_PATH, JSON.stringify(grammarData, null, 2), 'utf8');

  console.log(`Wrote ${WORDS_PATH} (words: ${wordData.words.length})`);
  console.log(`Wrote ${GRAMMAR_PATH} (items: ${grammarData.length})`);

  await browser.close();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
