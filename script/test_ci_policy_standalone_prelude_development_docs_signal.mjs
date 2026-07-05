import fs from "node:fs"

const packageJson = JSON.parse(fs.readFileSync("package.json", "utf8"))
const docs = [
  [
    "docs/en/development.md",
    fs.readFileSync("docs/en/development.md", "utf8"),
    [
      "standalone LICENSE package-sensitive prelude",
      "`script/test_license_package_sensitive_signal.mjs`",
      "representative signal for LICENSE package-sensitive routing",
      "package script composition",
      "not as a `script/test_ci_policy_suite.mjs` checks-array group"
    ]
  ],
  [
    "docs/ja/development.md",
    fs.readFileSync("docs/ja/development.md", "utf8"),
    [
      "standalone の LICENSE package-sensitive prelude",
      "`script/test_license_package_sensitive_signal.mjs`",
      "LICENSE package-sensitive routing の代表 signal",
      "package script composition",
      "`script/test_ci_policy_suite.mjs` の checks array group ではなく"
    ]
  ]
]

const expectedPreludeCommand = "node script/test_license_package_sensitive_signal.mjs"
const expectedCiPolicyCommand = `${expectedPreludeCommand} && node script/test_ci_policy_suite.mjs --self-test && node script/test_ci_policy_suite.mjs`
const developmentDocsSignalCommand = "node script/test_ci_policy_standalone_prelude_development_docs_signal.mjs"
const missingSignals = []

const ciPolicyScript = packageJson.scripts?.["test:ci-policy"]
if (ciPolicyScript !== expectedCiPolicyCommand) {
  missingSignals.push(
    `package.json scripts.test:ci-policy: expected standalone prelude package script composition ${expectedCiPolicyCommand}`
  )
}

const developmentDocsScript = packageJson.scripts?.["test:development-docs-commands"]
if (!developmentDocsScript?.includes(developmentDocsSignalCommand)) {
  missingSignals.push(
    `package.json scripts.test:development-docs-commands: missing standalone prelude Development docs signal command ${developmentDocsSignalCommand}`
  )
}

for (const [docPath, doc, signals] of docs) {
  for (const signal of signals) {
    if (!doc.includes(signal)) {
      missingSignals.push(`${docPath}: missing standalone prelude package script composition docs signal ${signal}`)
    }
  }
}

if (missingSignals.length > 0) {
  console.error("[ci-policy-standalone-prelude-development-docs-signal] missing standalone prelude signals:")
  for (const signal of missingSignals) {
    console.error(`- ${signal}`)
  }
  process.exit(1)
}

console.log(
  `[ci-policy-standalone-prelude-development-docs-signal] ${docs.length} Development docs paths describe the standalone LICENSE package-sensitive prelude and package script composition`
)
