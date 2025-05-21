import { test, expect } from '@playwright/test';

test('Access 24Slides homepage and verify title', async ({ page }) => {
  await page.goto('https://24slides.com/');
  await expect(page).toHaveTitle(/24Slides/);
});
