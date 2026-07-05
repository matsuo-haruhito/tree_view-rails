import { readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
const manifestPath = "config/public_api_manifest.yml"

function read(relativePath) {
  return readFileSync(path.join(repoRoot, relativePath), "utf8")
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function assertIncludes(source, needle, label) {
  assert(source.includes(needle), `${label}: missing ${needle}`)
}

const manifest = read(manifestPath)
const publicApiDocs = [
  ["docs/en/public-api.md", read("docs/en/public-api.md")],
  ["docs/ja/public-api.md", read("docs/ja/public-api.md")]
]

const callbackBuilderKeys = [
  "row_class_builder",
  "row_data_builder",
  "row_event_payload_builder",
  "loading_builder",
  "error_builder",
  "depth_label_builder",
  "badge_builder",
  "icon_builder",
  "toggle_icon_builder"
]

assertIncludes(
  manifest,
  "render_state_callback_builder_keys:",
  `${manifestPath} RenderState callback builder manifest source`
)

callbackBuilderKeys.forEach((key) => {
  assertIncludes(manifest, `- ${key}`, `${manifestPath} RenderState callback builder key source`)
})

publicApiDocs.forEach(([relativePath, document]) => {
  assertIncludes(
    document,
    "render_state_callback_builder_keys",
    `${relativePath} RenderState callback builder manifest source reference`
  )

  callbackBuilderKeys.forEach((key) => {
    assertIncludes(document, key, `${relativePath} RenderState callback builder docs key from ${manifestPath}`)
  })

  assert(
    /key-surface contract|key surface の contract/.test(document),
    `${relativePath}: RenderState callback builder docs no longer describe the key-surface contract from ${manifestPath}`
  )
  assert(
    /callback arity|callback arity/.test(document),
    `${relativePath}: RenderState callback builder docs no longer preserve callback arity as outside this signal`
  )
  assert(
    /return[- ]value validation|return value validation/.test(document),
    `${relativePath}: RenderState callback builder docs no longer preserve return-value validation as outside this signal`
  )
  assert(
    /request lifecycle|request lifecycle/.test(document),
    `${relativePath}: RenderState callback builder docs no longer keep request lifecycle with the host app`
  )
  assert(
    /retry UI|retry UI/.test(document),
    `${relativePath}: RenderState callback builder docs no longer keep retry UI with the host app`
  )
  assert(
    /authorization-safe error copy|authorization-safe error copy/.test(document),
    `${relativePath}: RenderState callback builder docs no longer keep authorization-safe error copy with the host app`
  )
})
