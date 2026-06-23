import fs from "node:fs"

const packageJson = JSON.parse(fs.readFileSync("package.json", "utf8"))
const readme = fs.readFileSync("README.md", "utf8")
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

const requiredReadmeDevelopmentCommands = [
  "npm run test:js",
  "npm run test:entrypoints",
  "npm run test:docs-entrypoints",
  "npm run test:ci-policy"
]

const requiredDockerSetupSignals = [
  "cp .env.example .env",
  "docker compose build",
  "docker compose run --rm app bundle install",
  "docker compose run --rm app npm ci",
  "Node 22",
  "npm",
  "lockfile-backed install path"
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

for (const command of requiredReadmeDevelopmentCommands) {
  if (!readme.includes(command)) {
    missingSignals.push(`README.md Development command: ${command}`)
  }
}

for (const signal of requiredDockerSetupSignals) {
  for (const [docPath, doc] of docs) {
    if (!doc.includes(signal)) {
      missingSignals.push(`${docPath}: Docker setup signal ${signal}`)
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
  `[development-docs-command-signals] ${requiredMaintenanceScripts.length} maintenance commands, ${requiredReadmeDevelopmentCommands.length} README Development commands, and ${requiredDockerSetupSignals.length} Docker setup signals are present in package.json and docs`
)
