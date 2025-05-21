# QA Automation for 24Slides (Playwright)

![Playwright Tests](https://github.com/renohid/project/actions/workflows/playwright.yml/badge.svg)

This repo contains test cases for verifying login and download functionality on [24Slides Templates](https://24slides.com/templates/featured).

---

## 🔍 Test Scope
This QA project focuses on:
- Login functionality (Email/Password, Google, LinkedIn)
- Template download flow
- Field validations and UI visibility

---

## 🤖 Automation Coverage

### ✅ Automated
- UI validation (buttons, layout)
- Invalid login inputs (wrong password, invalid email)
- Form validation (empty fields)
- Simulated download button behavior

### ⚠️ Manual Only
- Google and LinkedIn login (OAuth)
- Actual file download (blocked by Cloudflare CAPTCHA)

---

## 🚧 Known Constraints
- Cloudflare human verification blocks full automation
- OAuth-based login flows can't be automated due to external redirect restrictions
- Actual download action triggers Cloudflare CAPTCHA

---

## ▶️ How to Run

```bash
npm install
npx playwright test
