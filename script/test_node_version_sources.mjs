import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const nvmrcMajor = readFileSync(".nvmrc", "utf8").trim();
const packageJson = JSON.parse(readFileSync("package.json", "utf8"));
const workflow = readFileSync(".github/workflows/ci.yml", "utf8");

const engineMajor = packageJson.engines?.node?.match(/\d+/)?.[0];
const workflowNodeVersions = [...workflow.matchAll(/node-version:\s*["']?(\d+)(?:\.x)?["']?/g)].map((match) => match[1]);

assert.match(nvmrcMajor, /^\d+$/, ".nvmrc should contain the recommended Node major version only");
assert.equal(engineMajor, nvmrcMajor, "package.json engines.node should match .nvmrc Node major");
assert.ok(workflowNodeVersions.length > 0, "CI workflow should declare at least one setup-node node-version");
assert.deepEqual(
  [...new Set(workflowNodeVersions)],
  [nvmrcMajor],
  "CI setup-node node-version values should match .nvmrc Node major"
);

console.log(`Checked Node ${nvmrcMajor} across .nvmrc, package.json, and CI workflow.`);
