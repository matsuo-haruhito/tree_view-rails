import fs from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")

function read(relativePath) {
  return fs.readFileSync(path.join(repoRoot, relativePath), "utf8")
}

function assertIncludes(source, relativePath, signal, label) {
  if (!source.includes(signal)) {
    throw new Error(`${relativePath}: missing ${label} signal: ${signal}`)
  }
}

const manifestPath = "config/public_api_manifest.yml"
const manifest = read(manifestPath)
const toggleIconsSection = manifest.match(/grouped_option_keys:[\s\S]*?  toggle_icons:\n(?<body>(?:    - .+\n)+)/)?.groups?.body

if (!toggleIconsSection) {
  throw new Error(`${manifestPath}: missing grouped_option_keys.toggle_icons section`)
}

for (const key of ["by_state", "by_depth", "by_type"]) {
  assertIncludes(toggleIconsSection, manifestPath, `- ${key}`, "toggle_icons grouped option key")
}

const docs = [
  {
    path: "docs/en/public-api.md",
    signals: [
      "| `toggle_icons` | `by_state`, `by_depth`, `by_type` |",
      "`toggle_icon_builder` remains a callable escape hatch and is not manifest-backed"
    ]
  },
  {
    path: "docs/ja/public-api.md",
    signals: [
      "| `toggle_icons` | `by_state`, `by_depth`, `by_type` |",
      "`toggle_icon_builder` は callable escape hatch のままで、manifest-backed grouped option には含めません"
    ]
  },
  {
    path: "docs/en/toggle-icons.md",
    signals: [
      "Use `toggle_icons:` when you want to configure multiple icons declaratively.",
      "Icons are selected in this order: `by_type`, then `by_depth`, then `by_state`.",
      "When both `toggle_icon_builder:` and `toggle_icons:` are supplied, the explicit `toggle_icon_builder:` takes precedence.",
      "Custom content only supplies the content rendered inside the toggle control."
    ]
  },
  {
    path: "docs/ja/toggle-icons.md",
    signals: [
      "複数の icon を declarative に指定したい場合は `toggle_icons:` を使います。",
      "選択順は `by_type` → `by_depth` → `by_state` です。",
      "`toggle_icon_builder:` と `toggle_icons:` を両方指定した場合は、明示的な `toggle_icon_builder:` が優先されます。",
      "custom content は toggle control の内側に描画する内容だけを返します。"
    ]
  }
]

for (const doc of docs) {
  const source = read(doc.path)

  for (const signal of doc.signals) {
    assertIncludes(source, doc.path, signal, "toggle_icons docs")
  }
}

console.log(`Verified toggle_icons docs signals across ${docs.length} docs and ${manifestPath}.`)
