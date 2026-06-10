export function classifyChangedFiles(files) {
  const result = {
    docs_only: true,
    mockups_changed: false,
    browser_smoke_changed: false,
    package_sensitive: false,
    docker_setup_sensitive: false
  };

  for (const file of files.map((entry) => entry.trim()).filter(Boolean)) {
    if (!isDocsOnlyPath(file)) {
      result.docs_only = false;
    }

    if (file.startsWith("docs/mockups/")) {
      result.mockups_changed = true;
    }

    if (file.startsWith("test/browser/")) {
      result.browser_smoke_changed = true;
    }

    if (isPackageSensitivePath(file)) {
      result.package_sensitive = true;
    }

    if (isDockerSetupSensitivePath(file)) {
      result.docker_setup_sensitive = true;
    }
  }

  return result;
}

function isDocsOnlyPath(file) {
  return (
    file === "README.md" ||
    file.startsWith("docs/") ||
    file === "Product Profile.md" ||
    file === "CHANGELOG.md" ||
    file === "AGENTS.md"
  );
}

function isPackageSensitivePath(file) {
  return (
    file === "README.md" ||
    file === "CHANGELOG.md" ||
    file.startsWith("docs/") ||
    file === "tree_view.gemspec" ||
    file === "package.json" ||
    file === "package-lock.json" ||
    file === ".nvmrc" ||
    file === "script/check_gem_package_contents.rb" ||
    file === ".github/workflows/ci.yml" ||
    file === "config/importmap.tree_view.rb" ||
    file === "config/public_api_manifest.yml" ||
    file.startsWith("lib/") ||
    file.startsWith("app/helpers/") ||
    file.startsWith("app/views/") ||
    file.startsWith("app/assets/") ||
    file.startsWith("app/javascript/") ||
    file.startsWith("config/locales/")
  );
}

function isDockerSetupSensitivePath(file) {
  return (
    file === "Dockerfile" ||
    file === "docker-compose.yml" ||
    file === "package.json" ||
    file === "package-lock.json" ||
    file === ".nvmrc"
  );
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const input = await readStdin();
  const result = classifyChangedFiles(input.split(/\r?\n/));

  for (const [key, value] of Object.entries(result)) {
    console.log(`${key}=${value}`);
  }
}

function readStdin() {
  return new Promise((resolve) => {
    let data = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => {
      data += chunk;
    });
    process.stdin.on("end", () => {
      resolve(data);
    });
  });
}
