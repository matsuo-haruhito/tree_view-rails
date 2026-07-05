import { execFileSync } from "node:child_process"
import { readFileSync } from "node:fs"

const MANIFEST_PATH = "config/public_api_manifest.yml"
const STYLESHEET_PATH = "app/assets/stylesheets/tree_view.scss"

function loadManifest() {
  try {
    return JSON.parse(
      execFileSync(
        "ruby",
        [
          "-rjson",
          "-ryaml",
          "-e",
          "print JSON.generate(YAML.load_file(ARGV.fetch(0)))",
          MANIFEST_PATH
        ],
        { encoding: "utf8" }
      )
    )
  } catch (error) {
    const detail = [error.stdout, error.stderr]
      .filter((output) => output && output.length > 0)
      .join("\n")
      .trim() || error.message

    throw new Error(
      [
        `Could not load ${MANIFEST_PATH} for the CSS custom property manifest smoke.`,
        "Run this command from the repository root with Ruby available, or inspect the manifest YAML syntax.",
        `Loader output: ${detail}`
      ].join("\n"),
      { cause: error }
    )
  }
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function stylesheetCustomPropertyTokens(source) {
  const tokens = new Set()
  const tokenPattern = /var\(\s*(--tree-view-[a-z0-9-]+)/g

  let match
  while ((match = tokenPattern.exec(source)) !== null) {
    tokens.add(match[1])
  }

  return tokens
}

const manifest = loadManifest()
const manifestTokens = manifest.css_custom_property_tokens

assert(
  Array.isArray(manifestTokens) && manifestTokens.length > 0,
  "config/public_api_manifest.yml css_custom_property_tokens must be a non-empty array"
)

const stylesheetSource = readFileSync(STYLESHEET_PATH, "utf8")
const stylesheetTokens = stylesheetCustomPropertyTokens(stylesheetSource)
const manifestTokenSet = new Set(manifestTokens)
const missingFromStylesheet = manifestTokens.filter((token) => !stylesheetTokens.has(token))
const extraInStylesheet = [...stylesheetTokens].filter((token) => !manifestTokenSet.has(token)).sort()

assert(
  missingFromStylesheet.length === 0,
  [
    `${STYLESHEET_PATH} is missing manifest CSS custom property token(s):`,
    missingFromStylesheet.join(", "),
    `Keep ${MANIFEST_PATH} css_custom_property_tokens aligned with packaged stylesheet var(--tree-view-*) usage.`
  ].join("\n")
)

assert(
  extraInStylesheet.length === 0,
  [
    `${STYLESHEET_PATH} uses CSS custom property token(s) not listed in ${MANIFEST_PATH}:`,
    extraInStylesheet.join(", "),
    "Add intentional public stylesheet override tokens to css_custom_property_tokens, or rename the stylesheet usage."
  ].join("\n")
)

console.log("CSS custom property manifest stylesheet signal passed.")
