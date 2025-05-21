# QA Automation for 24Slides (Playwright)

This repo contains test cases for verifying login and download on https://24slides.com/templates/featured.

## ⚠️ Note on Automation Limitation

Due to Cloudflare's bot protection, full login flow and template download are **blocked for automation**.  
This repo includes:
- Manual test coverage in Google Sheet
- Placeholder automation test (`placeholder.spec.ts`)
- Pseudocode to represent full flow

## ✅ How to Run

```bash
npm install
npx playwright test

![CI](https://github.com/renohid/project/actions/workflows/playwright.yml/badge.svg)
