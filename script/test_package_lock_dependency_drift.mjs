import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const packagePath = "package.json";
const packageLockPath = "package-lock.json";

function dependencyKeys(metadata, section) {
  return Object.keys(metadata?.[section] || {}).sort();
}

function dependencySpecs(metadata, section) {
  return metadata?.[section] || {};
}

function assertDependencyKeysMatch(packageMetadata, lockRootPackage, section) {
  const packageKeys = dependencyKeys(packageMetadata, section);
  const lockKeys = dependencyKeys(lockRootPackage, section);
  const missingFromLock = packageKeys.filter((key) => !lockKeys.includes(key));
  const extraInLock = lockKeys.filter((key) => !packageKeys.includes(key));

  assert.deepEqual(
    { missingFromLock, extraInLock },
    { missingFromLock: [], extraInLock: [] },
    `${packageLockPath} root package ${section} keys must match ${packagePath} ${section} keys`
  );
}

function assertDependencySpecsMatch(packageMetadata, lockRootPackage, section) {
  const packageSpecs = dependencySpecs(packageMetadata, section);
  const lockSpecs = dependencySpecs(lockRootPackage, section);
  const mismatches = dependencyKeys(packageMetadata, section)
    .filter((key) => packageSpecs[key] !== lockSpecs[key])
    .map((key) => ({
      section,
      name: key,
      packageJson: packageSpecs[key],
      packageLock: lockSpecs[key]
    }));

  assert.deepEqual(
    mismatches,
    [],
    `${packageLockPath} root package ${section} specs must match ${packagePath} ${section} specs`
  );
}

function assertRootPackageEnginesMatch(packageMetadata, lockRootPackage) {
  assert.deepEqual(
    lockRootPackage.engines || {},
    packageMetadata.engines || {},
    `${packageLockPath} root package engines must match ${packagePath} engines; run npm install after changing Node engine metadata`
  );
}

const packageMetadata = JSON.parse(readFileSync(packagePath, "utf8"));
const packageLock = JSON.parse(readFileSync(packageLockPath, "utf8"));
const lockRootPackage = packageLock.packages?.[""];

assert.ok(lockRootPackage, `${packageLockPath} must include packages[""] root package metadata`);

assertRootPackageEnginesMatch(packageMetadata, lockRootPackage);

for (const section of ["dependencies", "devDependencies"]) {
  assertDependencyKeysMatch(packageMetadata, lockRootPackage, section);
  assertDependencySpecsMatch(packageMetadata, lockRootPackage, section);
}
