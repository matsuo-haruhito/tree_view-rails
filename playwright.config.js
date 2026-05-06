import { defineConfig, devices } from "@playwright/test"

const chromiumLaunchOptions = process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH
  ? { executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH, args: ["--no-sandbox"] }
  : { args: ["--no-sandbox"] }

export default defineConfig({
  testDir: "./test/browser",
  timeout: 10_000,
  expect: {
    timeout: 2_000
  },
  use: {
    baseURL: "http://localhost:4173",
    trace: "on-first-retry"
  },
  webServer: {
    command: "npx vite app/javascript/tree_view --host localhost --port 4173 --strictPort",
    url: "http://localhost:4173/browser_smoke.html",
    reuseExistingServer: !process.env.CI,
    timeout: 30_000
  },
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        launchOptions: chromiumLaunchOptions
      }
    }
  ]
})
