import fs from "node:fs"

const packageJson = JSON.parse(fs.readFileSync("package.json", "utf8"))
const readme = fs.readFileSync("README.md", "utf8")
const workflow = fs.readFileSync(".github/workflows/ci.yml", "utf8")
const docs = [
  ["docs/en/development.md", fs.readFileSync("docs/en/development.md", "utf8")],
  ["docs/ja/development.md", fs.readFileSync("docs/ja/development.md", "utf8")]
]
const releaseDocs = [
  ["docs/en/release.md", fs.readFileSync("docs/en/release.md", "utf8")],
  ["docs/ja/release.md", fs.readFileSync("docs/ja/release.md", "utf8")]
]
const ciPolicySuiteDocs = [
  [
    "docs/en/ci-policy-suite.md",
    fs.readFileSync("docs/en/ci-policy-suite.md", "utf8"),
    ["checks", "explicit exclusion"]
  ],
  [
    "docs/ja/ci-policy-suite.md",
    fs.readFileSync("docs/ja/ci-policy-suite.md", "utf8"),
    ["checks", "明示的な exclusion"]
  ]
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

const requiredCiPolicySuiteCommandSignals = [
  "npm run test:ci-policy",
  "node script/test_ci_policy_suite.mjs --list",
  "node script/test_ci_policy_suite.mjs --only <group-or-index>",
  "node script/test_ci_policy_suite.mjs --self-test"
]

const requiredReleaseCiPolicySuiteSignals = [
  "ci-policy-suite.md",
  "node script/test_ci_policy_suite.mjs --list",
  "node script/test_ci_policy_suite.mjs --only <group-or-index>",
  "node script/test_ci_policy_suite.mjs --self-test"
]

const requiredDevelopmentCiPolicySignals = [
  [
    "docs/en/development.md",
    [
      "Pull requests run the fast Ruby checks and JavaScript checks",
      "Pushes to `main` also run the broader compatibility and release checks",
      "changed-files policy",
      "ci_policy_sensitive",
      "npm run test:ci-policy"
    ]
  ],
  [
    "docs/ja/development.md",
    [
      "Pull Requestでは、日常的な変更を守る高速なRuby checksとJavaScript checksを実行します",
      "`main` へのpushでは、より広い互換性確認とrelease向けのchecksも実行します",
      "changed-files policy",
      "ci_policy_sensitive",
      "npm run test:ci-policy"
    ]
  ]
]

const requiredReleaseCiPolicySensitiveSignals = [
  [
    "docs/en/release.md",
    [
      "CI-policy-sensitive docs-only PRs run `npm run test:ci-policy`",
      "Docs-only PRs that are not docs-entrypoint-sensitive and do not touch mockups, CI-policy-sensitive, or browser-smoke-sensitive paths can skip JavaScript checks entirely",
      "changed-files policy"
    ]
  ],
  [
    "docs/ja/release.md",
    [
      "CI-policy-sensitive な docs-only PR では `npm run test:ci-policy`",
      "docs-entrypoint-sensitive でも CI-policy-sensitive でもなく、mockup / browser-smoke path も触らない docs-only PR は JavaScript checks を完全に skip できます",
      "changed-files policy"
    ]
  ]
]

const requiredWorkflowTriggerSignals = [
  "on:\n  pull_request:",
  "push:\n    branches:\n      - main"
]

const missingSignals = []

function docSource(docList, docPath) {
  return docList.find(([path]) => path === docPath)?.[1]
}

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

for (const [docPath, doc, registrationSignals] of ciPolicySuiteDocs) {
  for (const signal of requiredCiPolicySuiteCommandSignals) {
    if (!doc.includes(signal)) {
      missingSignals.push(`${docPath}: CI policy suite docs command signal ${signal}`)
    }
  }

  for (const signal of registrationSignals) {
    if (!doc.includes(signal)) {
      missingSignals.push(`${docPath}: CI policy suite registration signal ${signal}`)
    }
  }
}

for (const [docPath, doc] of releaseDocs) {
  for (const signal of requiredReleaseCiPolicySuiteSignals) {
    if (!doc.includes(signal)) {
      missingSignals.push(`${docPath}: CI policy suite release entrypoint signal ${signal}`)
    }
  }
}

for (const [docPath, signals] of requiredDevelopmentCiPolicySignals) {
  const doc = docSource(docs, docPath)

  for (const signal of signals) {
    if (!doc?.includes(signal)) {
      missingSignals.push(`${docPath}: CI policy trigger/routing signal ${signal}`)
    }
  }
}

for (const [docPath, signals] of requiredReleaseCiPolicySensitiveSignals) {
  const doc = docSource(releaseDocs, docPath)

  for (const signal of signals) {
    if (!doc?.includes(signal)) {
      missingSignals.push(`${docPath}: CI policy-sensitive release docs signal ${signal}`)
    }
  }
}

for (const signal of requiredWorkflowTriggerSignals) {
  if (!workflow.includes(signal)) {
    missingSignals.push(`.github/workflows/ci.yml: CI workflow trigger signal ${signal}`)
  }
}

if (workflow.includes("pull_request_target")) {
  missingSignals.push(".github/workflows/ci.yml: CI workflow must not use pull_request_target for PR checks")
}

if (missingSignals.length > 0) {
  console.error("[development-docs-command-signals] missing maintenance command signals:")
  for (const signal of missingSignals) {
    console.error(`- ${signal}`)
  }
  process.exit(1)
}

console.log(
  `[development-docs-command-signals] ${requiredMaintenanceScripts.length} maintenance commands, ${requiredReadmeDevelopmentCommands.length} README Development commands, ${requiredDockerSetupSignals.length} Docker setup signals, ${requiredCiPolicySuiteCommandSignals.length} CI policy suite command signals, ${requiredReleaseCiPolicySuiteSignals.length} release entrypoint signals, ${requiredDevelopmentCiPolicySignals.length} CI policy docs groups, ${requiredReleaseCiPolicySensitiveSignals.length} release CI policy docs groups, and ${requiredWorkflowTriggerSignals.length} workflow trigger signals are present in package.json, workflow, and docs`
)
