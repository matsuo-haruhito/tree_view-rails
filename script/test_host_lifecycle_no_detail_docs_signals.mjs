import assert from "node:assert/strict"
import { readFileSync } from "node:fs"

function readText(path) {
  return readFileSync(path, "utf8")
}

function assertIncludes(source, expected, context) {
  assert.ok(
    source.includes(expected),
    `${context} should include ${expected}`
  )
}

function assertMatches(source, pattern, context) {
  assert.match(source, pattern, `${context} should match ${pattern}`)
}

function sectionBetween(source, startMarker, endMarker, context) {
  const start = source.indexOf(startMarker)
  assert.notEqual(start, -1, `${context} should include ${startMarker.trim()}`)

  const end = source.indexOf(endMarker, start + startMarker.length)
  assert.notEqual(end, -1, `${context} should include ${endMarker.trim()} after ${startMarker.trim()}`)

  return source.slice(start + startMarker.length, end)
}

const manifest = readText("config/public_api_manifest.yml")
const publicApiEn = readText("docs/en/public-api.md")
const publicApiJa = readText("docs/ja/public-api.md")
const lazyLoadingEn = readText("docs/en/lazy-loading.md")
const lazyLoadingJa = readText("docs/ja/lazy-loading.md")

const lifecycleNames = ["loading", "loaded", "error", "retry"]
const noDetailSection = sectionBetween(
  manifest,
  "  event_names_without_detail:\n",
  "  event_detail_keys:\n",
  "public API manifest"
)
const detailKeysSection = sectionBetween(
  manifest,
  "  event_detail_keys:\n",
  "  integration_hooks:\n",
  "public API manifest"
)

assertIncludes(noDetailSection, "    host_lifecycle:", "event_names_without_detail section")
for (const name of lifecycleNames) {
  assertIncludes(noDetailSection, `      - ${name}`, "host_lifecycle no-detail event names")
}
assert.doesNotMatch(
  detailKeysSection,
  /^    host_lifecycle:/m,
  "host_lifecycle events should stay out of event_detail_keys because they do not define public event.detail payload keys"
)

assertMatches(
  publicApiEn,
  /TreeViewEventNames\.hostLifecycle\.\*[\s\S]*host-app dispatch surface[\s\S]*TreeViewEventNames\.remoteState\.\*/,
  "English public API docs hostLifecycle boundary"
)
assertMatches(
  publicApiJa,
  /TreeViewEventNames\.hostLifecycle\.\*[\s\S]*host app 側の request-state dispatch 専用[\s\S]*TreeViewEventNames\.remoteState\.\*/,
  "Japanese public API docs hostLifecycle boundary"
)

assertMatches(
  lazyLoadingEn,
  /TreeViewEventNames\.hostLifecycle\.loading[\s\S]*\.loaded[\s\S]*\.error[\s\S]*\.retry[\s\S]*host-app request-state dispatch[\s\S]*TreeViewEventNames\.remoteState\.\*/,
  "English lazy-loading docs hostLifecycle lifecycle boundary"
)
assertMatches(
  lazyLoadingJa,
  /TreeViewEventNames\.hostLifecycle\.loading[\s\S]*\.loaded[\s\S]*\.error[\s\S]*\.retry[\s\S]*host app 側の request-state dispatch 専用[\s\S]*TreeViewEventNames\.remoteState\.\*/,
  "Japanese lazy-loading docs hostLifecycle lifecycle boundary"
)

assertMatches(
  lazyLoadingEn,
  /TreeViewRemoteStateValues\.loading[\s\S]*not event names[\s\S]*not a validation list/,
  "English lazy-loading docs remote-state values boundary"
)
assertMatches(
  lazyLoadingJa,
  /TreeViewRemoteStateValues\.loading[\s\S]*event 名ではありません[\s\S]*validation list でもありません/,
  "Japanese lazy-loading docs remote-state values boundary"
)

console.log("[host-lifecycle-docs] no-detail host lifecycle docs signals passed")
