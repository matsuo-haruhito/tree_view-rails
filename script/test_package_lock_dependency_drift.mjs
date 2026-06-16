import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const packagePath = "package.json";
const packageLockPath = "package-lock.json";

function dependencyKeys(metadata, section) {
  return Object.keys(metadata?.[section] || {}).sort();
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

const packageMetadata = JSON.parse(readFileSync(packagePath, "utf8"));
const packageLock = JSON.parse(readFileSync(packageLockPath, "utf8"));
const lockRootPackage = packageLock.packages?.[""];

assert.ok(lockRootPackage, `${packageLockPath} must include packages[""] root package metadata`);

for (const section of ["dependencies", "devDependencies"]) {
  assertDependencyKeysMatch(packageMetadata, lockRootPackage, section);
}
