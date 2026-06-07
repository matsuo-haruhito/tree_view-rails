# frozen_string_literal: true

require "json"
require "pathname"

RSpec.describe "Node version source drift" do
  let(:repository_root) { Pathname.new(__dir__).join("..").expand_path }

  def read_repository_file(path)
    repository_root.join(path).read
  end

  it "keeps .nvmrc, package engines, and CI node-version on the same major" do
    nvmrc_major = read_repository_file(".nvmrc").strip.delete_prefix("v").split(".").first
    package_json = JSON.parse(read_repository_file("package.json"))
    engine_major = package_json.fetch("engines").fetch("node").match(/\d+/)[0]
    workflow_versions = read_repository_file(".github/workflows/ci.yml")
      .scan(/node-version:\s*["']?(\d+)/)
      .flatten
      .uniq

    expect(engine_major).to eq(nvmrc_major)
    expect(workflow_versions).to eq([nvmrc_major])
  end

  it "keeps development docs aligned with the guarded source of truth" do
    %w[docs/en/development.md docs/ja/development.md].each do |path|
      content = read_repository_file(path)

      expect(content).to include("Node 22")
      expect(content).to include(".nvmrc")
      expect(content).to include("package.json")
      expect(content).to include("node-version")
    end
  end
end
