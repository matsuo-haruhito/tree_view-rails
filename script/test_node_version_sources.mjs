import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = dirname(fileURLToPath(new URL("../package.json", import.meta.url)));
const packageJson = JSON.parse(readFileSync(join(repoRoot, "package.json"), "utf8"));
const nvmrc = readFileSync(join(repoRoot, ".nvmrc"), "utf8").trim();
const workflow = readFileSync(join(repoRoot, ".github/workflows/ci.yml"), "utf8");
const dockerfile = readFileSync(join(repoRoot, "Dockerfile"), "utf8");

const workflowNodeVersions = Array.from(workflow.matchAll(/node-version:\s*["']?(\d+)["']?/g), (match) => match[1]);
const dockerNodeMajorMatch = dockerfile.match(/^ARG\s+NODE_MAJOR=(\d+)\s*$/m);

assert.equal(nvmrc, "22", ".nvmrc must keep Node 22 as the local source of truth");
assert.equal(packageJson.engines.node, "22.x", "package.json engines.node must stay aligned with .nvmrc");
assert.deepEqual(workflowNodeVersions, ["22"], "CI workflow node-version values must stay aligned with .nvmrc");
assert.ok(dockerNodeMajorMatch, "Dockerfile must declare ARG NODE_MAJOR so Docker development setup stays aligned with .nvmrc");
assert.equal(dockerNodeMajorMatch[1], nvmrc, "Dockerfile ARG NODE_MAJOR must stay aligned with .nvmrc");

console.log("Node version sources stay aligned with Node 22.");
