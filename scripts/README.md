# Scraper scripts

## 설치

```bash
npm install
npx playwright install chromium
```

## N5 단어/문법 스크랩

```bash
npm run scrape:n5
```

Outputs:
- `Data/jlptcode/n5_words.json`
- `Data/jlptcode/n5_grammar.json`

## 전체(N5~N1) 단어/문법 스크랩

```bash
npm run scrape:all
```

Outputs:
- `Data/jlptcode/n1_words.json` ... `n5_words.json`
- `Data/jlptcode/n1_grammar.json` ... `n5_grammar.json`

Note:
- 사이트 정책/약관을 확인하고, 요청 간 딜레이를 유지하세요.
- 데이터 파일은 기본적으로 gitignore 처리되어 있어요.
