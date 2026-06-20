import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const gemfilePath = "Gemfile";
const lockfilePath = "Gemfile.lock";

function stripComments(line) {
  const commentIndex = line.indexOf("#");
  return commentIndex === -1 ? line : line.slice(0, commentIndex);
}

function parseQuotedArguments(source) {
  return Array.from(source.matchAll(/['"]([^'"]+)['"]/g), (match) => match[1]);
}

function normalizeRequirement(parts) {
  return parts.length === 0 ? null : parts.join(", ");
}

function parseGemfileDirectDependencies(contents) {
  return contents
    .split(/\r?\n/)
    .map((line) => stripComments(line).trim())
    .filter((line) => line.startsWith("gem "))
    .map((line) => {
      const quotedArguments = parseQuotedArguments(line);
      const [name, ...requirements] = quotedArguments;

      return {
        name,
        requirement: normalizeRequirement(requirements.filter((value) => /^[<>=~!]/.test(value)))
      };
    })
    .filter((dependency) => dependency.name)
    .sort((left, right) => left.name.localeCompare(right.name));
}

function parseLockfileDependencies(contents) {
  const dependencies = new Map();
  const lines = contents.split(/\r?\n/);
  const dependenciesIndex = lines.findIndex((line) => line.trim() === "DEPENDENCIES");

  if (dependenciesIndex === -1) return dependencies;

  for (const line of lines.slice(dependenciesIndex + 1)) {
    if (!line.trim()) break;
    if (!line.startsWith("  ")) break;

    const entry = line.trim();
    const match = entry.match(/^([^(!]+?)(?: \(([^)]+)\))?(?:!)?$/);
    if (!match) continue;

    dependencies.set(match[1].trim(), match[2] || null);
  }

  return dependencies;
}

function dependencyMismatch(gemfileDependency, lockDependencies) {
  const lockRequirement = lockDependencies.get(gemfileDependency.name);

  if (!lockDependencies.has(gemfileDependency.name)) {
    return {
      name: gemfileDependency.name,
      gemfile: gemfileDependency.requirement,
      lockfile: undefined,
      reason: "missing from Gemfile.lock DEPENDENCIES"
    };
  }

  if (gemfileDependency.requirement !== lockRequirement) {
    return {
      name: gemfileDependency.name,
      gemfile: gemfileDependency.requirement,
      lockfile: lockRequirement,
      reason: "requirement mismatch"
    };
  }

  return null;
}

const gemfile = readFileSync(gemfilePath, "utf8");
const lockfile = readFileSync(lockfilePath, "utf8");
const gemfileDependencies = parseGemfileDirectDependencies(gemfile);
const lockDependencies = parseLockfileDependencies(lockfile);
const mismatches = gemfileDependencies
  .map((dependency) => dependencyMismatch(dependency, lockDependencies))
  .filter(Boolean);

assert.deepEqual(
  mismatches,
  [],
  `${lockfilePath} DEPENDENCIES must match direct ${gemfilePath} gem requirements; run bundle install after changing Gemfile dependency metadata`
);

console.log("tree_view Gemfile.lock dependency drift smoke passed");
