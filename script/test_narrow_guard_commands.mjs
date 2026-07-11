import fs from "node:fs"

const packageJson = JSON.parse(fs.readFileSync("package.json", "utf8"))
const docs = [
  ["docs/en/development.md", fs.readFileSync("docs/en/development.md", "utf8")],
  ["docs/ja/development.md", fs.readFileSync("docs/ja/development.md", "utf8")]
]

const expectedScripts = new Map([
  [
    "test:entrypoints-composition",
    "node script/test_entrypoints_package_script_composition.mjs"
  ],
  [
    "test:ci-policy-license-prelude",
    "node script/test_license_package_sensitive_signal.mjs"
  ],
  [
    "test:immutable-package-root-export-signals",
    "node script/test_immutable_package_root_export_signals.mjs"
  ]
])

const developmentDocsScript = packageJson.scripts?.["test:development-docs-commands"] || ""
const missingSignals = []

for (const [scriptName, command] of expectedScripts) {
  if (packageJson.scripts?.[scriptName] !== command) {
    missingSignals.push(`package.json scripts.${scriptName}: expected ${command}`)
  }
}

if (!developmentDocsScript.includes("node script/test_narrow_guard_commands.mjs")) {
  missingSignals.push(
    "package.json scripts.test:development-docs-commands: missing narrow guard command alias signal"
  )
}

if (!developmentDocsScript.includes("node script/test_entrypoints_package_script_composition.mjs")) {
  missingSignals.push(
    "package.json scripts.test:development-docs-commands: missing entrypoints package script composition guard"
  )
}

const entrypointsScript = packageJson.scripts?.["test:entrypoints"] || ""
if (!entrypointsScript.includes("node script/test_immutable_package_root_export_signals.mjs")) {
  missingSignals.push(
    "package.json scripts.test:entrypoints: missing immutable package-root export docs signal guard"
  )
}

for (const [docPath, doc] of docs) {
  if (!doc.includes("npm run test:development-docs-commands")) {
    missingSignals.push(`${docPath}: missing Development docs command signal entrypoint`)
  }

  if (!doc.includes("npm run test:ci-policy")) {
    missingSignals.push(`${docPath}: missing CI policy command entrypoint`)
  }
}

const standalonePreludeSignals = [
  [
    "docs/en/development.md",
    [
      "standalone LICENSE package-sensitive prelude",
      "`script/test_license_package_sensitive_signal.mjs`",
      "representative signal for LICENSE package-sensitive routing",
      "not as a `script/test_ci_policy_suite.mjs` checks-array group"
    ]
  ],
  [
    "docs/ja/development.md",
    [
      "standalone の LICENSE package-sensitive prelude",
      "`script/test_license_package_sensitive_signal.mjs`",
      "LICENSE package-sensitive routing の代表 signal",
      "`script/test_ci_policy_suite.mjs` の checks array group ではなく"
    ]
  ]
]

for (const [docPath, signals] of standalonePreludeSignals) {
  const doc = docs.find(([path]) => path === docPath)?.[1] || ""
  for (const signal of signals) {
    if (!doc.includes(signal)) {
      missingSignals.push(`${docPath}: missing standalone prelude signal ${signal}`)
    }
  }
}

if (missingSignals.length > 0) {
  console.error("[narrow-guard-commands] missing narrow maintenance command signals:")
  for (const signal of missingSignals) {
    console.error(`- ${signal}`)
  }
  process.exit(1)
}

console.log(
  `[narrow-guard-commands] ${expectedScripts.size} narrow guard command aliases and Development docs signals are present`
)
