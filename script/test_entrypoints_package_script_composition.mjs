import fs from "node:fs"

const packageJson = JSON.parse(fs.readFileSync("package.json", "utf8"))
const testEntrypointsCommand = packageJson.scripts?.["test:entrypoints"]

const requiredCommands = [
  "node script/test_entrypoints.mjs",
  "node script/test_controller_entries_contract.mjs",
  "node script/test_declaration_literal_shapes.mjs",
  "node script/test_immutable_package_root_export_signals.mjs",
  "node script/test_render_state_callback_builder_docs_signals.mjs",
  "npm run test:public-api-manifest-structure",
  "npm run test:css-custom-property-manifest",
  "npm run test:toggle-icons-docs",
  "npm run test:docs-entrypoints",
  "npm run test:ci-policy",
  "npm run test:node-version-sources",
  "npm run test:ruby-version-sources"
]

const missingCommands = []
const outOfOrderCommands = []

if (typeof testEntrypointsCommand !== "string" || testEntrypointsCommand.trim() === "") {
  missingCommands.push("package.json scripts.test:entrypoints")
} else {
  let lastCommandIndex = -1

  for (const requiredCommand of requiredCommands) {
    const commandIndex = testEntrypointsCommand.indexOf(requiredCommand)

    if (commandIndex === -1) {
      missingCommands.push(requiredCommand)
      continue
    }

    if (commandIndex < lastCommandIndex) {
      outOfOrderCommands.push(requiredCommand)
      continue
    }

    lastCommandIndex = commandIndex
  }
}

if (missingCommands.length > 0 || outOfOrderCommands.length > 0) {
  console.error("[entrypoints-package-script-composition] package.json scripts.test:entrypoints drift detected")

  if (missingCommands.length > 0) {
    console.error("[entrypoints-package-script-composition] missing commands:")
    for (const missingCommand of missingCommands) {
      console.error(`- ${missingCommand}`)
    }
  }

  if (outOfOrderCommands.length > 0) {
    console.error("[entrypoints-package-script-composition] commands out of expected order:")
    for (const outOfOrderCommand of outOfOrderCommands) {
      console.error(`- ${outOfOrderCommand}`)
    }
  }

  console.error("[entrypoints-package-script-composition] package.json scripts.test:entrypoints:")
  console.error(testEntrypointsCommand ?? "<missing>")
  process.exit(1)
}

console.log(
  `[entrypoints-package-script-composition] package.json scripts.test:entrypoints includes ${requiredCommands.length} required maintenance commands in order`
)
