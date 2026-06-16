import fs from "node:fs"

const packageJson = JSON.parse(fs.readFileSync("package.json", "utf8"))
const docs = [
  ["docs/en/development.md", fs.readFileSync("docs/en/development.md", "utf8")],
  ["docs/ja/development.md", fs.readFileSync("docs/ja/development.md", "utf8")]
]

const requiredMaintenanceScripts = [
  "test:docs-entrypoints",
  "test:ci-policy",
  "test:node-version-sources",
  "test:ruby-version-sources",
  "test:public-api-manifest-structure",
  "test:docs-i18n"
]

const missingSignals = []

for (const scriptName of requiredMaintenanceScripts) {
  if (!packageJson.scripts?.[scriptName]) {
    missingSignals.push(`package.json scripts.${scriptName}`)
    continue
  }

  const command = `npm run ${scriptName}`

  for (const [docPath, doc] of docs) {
    if (!doc.includes(command)) {
      missingSignals.push(`${docPath}: ${command}`)
    }
  }
}

if (missingSignals.length > 0) {
  console.error("[development-docs-command-signals] missing maintenance command signals:")
  for (const signal of missingSignals) {
    console.error(`- ${signal}`)
  }
  process.exit(1)
}

console.log(
  `[development-docs-command-signals] ${requiredMaintenanceScripts.length} maintenance commands are present in package.json and both Development docs`
)
