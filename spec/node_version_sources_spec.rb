# frozen_string_literal: true

require "json"
require "spec_helper"

module NodeVersionSourcesSpec
  ROOT = File.expand_path("..", __dir__)

  module_function

  def read(path)
    File.read(File.join(ROOT, path))
  end

  def nvmrc_major
    read(".nvmrc").strip
  end

  def package_engine_major
    engines = JSON.parse(read("package.json")).fetch("engines")
    engines.fetch("node").match(/\A(?<major>\d+)/).fetch(:major)
  end

  def ci_node_major
    workflow = read(".github/workflows/ci.yml")
    workflow.match(/node-version:\s*["']?(?<major>\d+)/).fetch(:major)
  end

  def development_docs
    %w[docs/en/development.md docs/ja/development.md]
  end
end

RSpec.describe "Node version source drift" do
  it "keeps package and CI Node majors aligned with .nvmrc" do
    expected_major = NodeVersionSourcesSpec.nvmrc_major

    aggregate_failures do
      expect(NodeVersionSourcesSpec.package_engine_major).to eq(expected_major),
        "package.json engines.node must match .nvmrc major #{expected_major}"
      expect(NodeVersionSourcesSpec.ci_node_major).to eq(expected_major),
        ".github/workflows/ci.yml JavaScript node-version must match .nvmrc major #{expected_major}"
    end
  end

  it "documents .nvmrc as the Node major source of truth" do
    expected_major = NodeVersionSourcesSpec.nvmrc_major

    aggregate_failures do
      NodeVersionSourcesSpec.development_docs.each do |path|
        content = NodeVersionSourcesSpec.read(path)

        expect(content).to include(".nvmrc"), "#{path} should name .nvmrc as the Node source of truth"
        expect(content).to include("Node #{expected_major}"), "#{path} should mention Node #{expected_major}"
        expect(content).to include("package.json"), "#{path} should mention package.json metadata drift"
        expect(content).to include("node-version"), "#{path} should mention workflow node-version drift"
      end
    end
  end
end
