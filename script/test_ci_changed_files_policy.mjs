import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { classifyChangedFiles } from "./ci_changed_files_policy.mjs";

const workflowPath = ".github/workflows/ci.yml";
const packagePath = "package.json";

const cases = [
  {
    name: "gem-packaged docs stay docs-only and request package and docs entrypoint guards",
    files: ["README.md", "docs/en/development.md", "docs/ja/development.md", "CHANGELOG.md"],
    expected: {
      docs_only: true,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: true
    }
  },
  {
    name: "repository-only docs stay docs-only without package or docs entrypoint guard",
    files: ["Product Profile.md", "AGENTS.md"],
    expected: {
      docs_only: true,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: false,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: false
    }
  },
  {
    name: "mockup docs remain docs-only but request browser smoke and package guard",
    files: ["docs/mockups/default-tree.html"],
    expected: {
      docs_only: true,
      mockups_changed: true,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: true
    }
  },
  {
    name: "browser smoke tests are not docs-only and request browser smoke",
    files: ["test/browser/docs_mockups_smoke.spec.js"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: true,
      package_sensitive: false,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: false
    }
  },
  {
    name: "workflow changes are package- and Docker-sensitive full CI changes",
    files: [".github/workflows/ci.yml"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: true,
      docs_entrypoint_sensitive: false
    }
  },
  {
    name: "public manifest changes request full JS and docs entrypoint guards",
    files: ["config/public_api_manifest.yml"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: true
    }
  },
  {
    name: "package-sensitive runtime files are not docs-only",
    files: ["app/javascript/tree_view/index.js", "config/public_api_manifest.yml"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: true
    }
  },
  {
    name: "Ruby dependency files are package-sensitive full CI changes",
    files: ["Gemfile", "Gemfile.lock"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: false
    }
  },
  {
    name: "package and Node metadata are package-sensitive full CI changes",
    files: ["package.json", "package-lock.json", ".nvmrc"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: true,
      docs_entrypoint_sensitive: false
    }
  },
  {
    name: "Docker setup files request Docker setup verification",
    files: ["Dockerfile", "docker-compose.yml"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: false,
      docker_setup_sensitive: true,
      docs_entrypoint_sensitive: false
    }
  }
];

function workflowChangesOutputs(workflowSource) {
  const outputsBlock = workflowSource.match(/^  changes:\n(?:    .*\n)*?    outputs:\n(?<body>(?:      [a-z_]+: .*\n)+)/m);
  assert.ok(outputsBlock, `${workflowPath} must define jobs.changes.outputs`);

  return [...outputsBlock.groups.body.matchAll(/^      (?<key>[a-z_]+): /gm)].map((match) => match.groups.key).sort();
}

function workflowJobBlock(workflowSource, jobName) {
  const marker = `  ${jobName}:\n`;
  const start = workflowSource.indexOf(marker);
  assert.notEqual(start, -1, `${workflowPath} must define jobs.${jobName}`);

  const bodyStart = start + marker.length;
  const remainingWorkflow = workflowSource.slice(bodyStart);
  const nextJobOffset = remainingWorkflow.search(/\n  [a-z_]+:\n/);

  return nextJobOffset === -1 ? remainingWorkflow : remainingWorkflow.slice(0, nextJobOffset + 1);
}

function workflowJavaScriptJob(workflowSource) {
  return workflowJobBlock(workflowSource, "javascript");
}

function npmRunScripts(workflowSource) {
  return [...workflowJavaScriptJob(workflowSource).matchAll(/run: npm run (?<script>[\w:-]+)/g)]
    .map((match) => match.groups.script)
    .sort();
}

function escapeRegExp(value) {
  return String(value).replace(/[\\^$.*+?()[\]{}|]/g, "\\$&");
}

function workflowActionVersions(workflowSource, actionName) {
  const pattern = new RegExp(`uses: ${escapeRegExp(actionName)}@(?<version>[^\\s]+)`, "g");
  return [...new Set([...workflowSource.matchAll(pattern)].map((match) => match.groups.version))].sort();
}

function assertSameMembers(actual, expected, message) {
  assert.deepEqual([...actual].sort(), [...expected].sort(), message);
}

function assertWorkflowActionVersions(workflowSource, actionName, expectedVersions) {
  assertSameMembers(
    workflowActionVersions(workflowSource, actionName),
    expectedVersions,
    `${workflowPath} must use ${actionName}@${expectedVersions.join(" or ")} for its representative setup surface`
  );
}

function assertJobMatches(jobBlock, pattern, message) {
  assert.match(jobBlock, pattern, message);
}

for (const testCase of cases) {
  assert.deepEqual(classifyChangedFiles(testCase.files), testCase.expected, testCase.name);
}

const policyKeys = Object.keys(classifyChangedFiles([])).sort();
const workflowSource = readFileSync(workflowPath, "utf8");
const packageScripts = JSON.parse(readFileSync(packagePath, "utf8")).scripts;
const workflowOutputKeys = workflowChangesOutputs(workflowSource);

assertSameMembers(
  workflowOutputKeys,
  policyKeys,
  `${workflowPath} jobs.changes.outputs must match classifyChangedFiles result keys`
);

assertWorkflowActionVersions(workflowSource, "actions/checkout", ["v6"]);
assertWorkflowActionVersions(workflowSource, "actions/setup-node", ["v6"]);
assertWorkflowActionVersions(workflowSource, "ruby/setup-ruby", ["v1"]);

const changesJob = workflowJobBlock(workflowSource, "changes");
assertJobMatches(
  changesJob,
  /uses: actions\/checkout@v6[\s\S]*fetch-depth: 0/,
  `${workflowPath} jobs.changes must keep a full checkout for changed-file detection`
);

const lintJob = workflowJobBlock(workflowSource, "lint");
assertJobMatches(lintJob, /ruby-version: "3\.3"/, `${workflowPath} jobs.lint must keep Ruby 3.3`);
assertJobMatches(lintJob, /bundler-cache: true/, `${workflowPath} jobs.lint must keep bundler-cache enabled`);

const javascriptJob = workflowJavaScriptJob(workflowSource);
assert.match(
  javascriptJob,
  /needs\.changes\.outputs\.docs_entrypoint_sensitive == 'true'/,
  `${workflowPath} jobs.javascript must keep docs_entrypoint_sensitive in its package-facing docs condition`
);
assert.match(
  javascriptJob,
  /run: npm run test:docs-entrypoints/,
  `${workflowPath} jobs.javascript must still run docs entrypoint checks for docs_entrypoint_sensitive changes`
);
assertJobMatches(javascriptJob, /uses: actions\/setup-node@v6/, `${workflowPath} jobs.javascript must keep setup-node v6`);
assertJobMatches(javascriptJob, /node-version: "22"/, `${workflowPath} jobs.javascript must keep the Node 22 CI lane`);
assertJobMatches(javascriptJob, /cache: npm/, `${workflowPath} jobs.javascript must keep npm cache enabled`);

const dockerDevelopmentSetupJob = workflowJobBlock(workflowSource, "docker_development_setup");
assertJobMatches(
  dockerDevelopmentSetupJob,
  /if: github\.event_name == 'pull_request' && needs\.changes\.outputs\.docker_setup_sensitive == 'true'/,
  `${workflowPath} jobs.docker_development_setup must stay gated by docker_setup_sensitive pull request changes`
);
assertJobMatches(
  dockerDevelopmentSetupJob,
  /needs: changes/,
  `${workflowPath} jobs.docker_development_setup must depend on changed-file detection`
);
assertJobMatches(
  dockerDevelopmentSetupJob,
  /run: docker compose build app/,
  `${workflowPath} jobs.docker_development_setup must keep the Docker app build smoke`
);
assertJobMatches(
  dockerDevelopmentSetupJob,
  /run: docker compose run --rm app/,
  `${workflowPath} jobs.docker_development_setup must keep the Docker app setup smoke`
);
assert.ok(
  dockerDevelopmentSetupJob.includes('node --version | grep -E "^v22\\." && npm --version && npm ci'),
  `${workflowPath} jobs.docker_development_setup must keep the representative Node/npm setup smoke`
);

const gemPackageJob = workflowJobBlock(workflowSource, "gem_package");
assertJobMatches(gemPackageJob, /ruby-version: "3\.3"/, `${workflowPath} jobs.gem_package must keep Ruby 3.3`);
assertJobMatches(gemPackageJob, /bundler-cache: true/, `${workflowPath} jobs.gem_package must keep bundler-cache enabled`);

for (const scriptName of npmRunScripts(workflowSource)) {
  assert.ok(
    Object.prototype.hasOwnProperty.call(packageScripts, scriptName),
    `${workflowPath} jobs.javascript runs npm script "${scriptName}", but ${packagePath} scripts does not define it`
  );
}

console.log(`Checked ${cases.length} CI changed-file policy cases.`);
console.log(`Checked ${workflowOutputKeys.length} workflow output keys and ${npmRunScripts(workflowSource).length} JavaScript npm commands.`);
console.log("Checked representative CI workflow setup surfaces.");
