# frozen_string_literal: true

require "spec_helper"
require "yaml"
require "generators/tree_view/state/install_generator"

RSpec.describe "Public setup generator compatibility" do
  MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
  GENERATOR_PATH = File.expand_path("../lib/generators/tree_view/state/install_generator.rb", __dir__)

  def public_api_manifest
    @public_api_manifest ||= YAML.safe_load_file(MANIFEST_PATH)
  end

  def state_install_generator_manifest
    public_api_manifest.fetch("setup_generators").fetch("persisted_state_install")
  end

  def state_install_generator_source
    @state_install_generator_source ||= File.read(GENERATOR_PATH)
  end

  it "keeps the persisted-state install generator in the public setup manifest" do
    manifest = state_install_generator_manifest
    generator = TreeView::Generators::State::InstallGenerator

    expect(manifest.fetch("name")).to eq("tree_view:state:install")
    expect(manifest.fetch("class_name")).to eq("TreeView::Generators::State::InstallGenerator")
    expect(generator.namespace).to eq(manifest.fetch("name"))

    owner_argument = generator.arguments.find { |argument| argument.name == "owner_model_name" }
    expect(owner_argument).not_to be_nil
    expect(owner_argument.required?).to be(false)
    expect(owner_argument.banner).to eq("OWNER_MODEL")
    expect(manifest.fetch("optional_arguments")).to eq([
      { "name" => "owner_model_name", "banner" => "OWNER_MODEL" }
    ])
  end

  it "keeps generated destination paths documented without freezing template contents" do
    manifest_paths = state_install_generator_manifest.fetch("generated_paths")

    expect(manifest_paths).to eq([
      "db/migrate/*_create_tree_view_states.rb",
      "app/models/tree_view_state.rb",
      "app/models/concerns/tree_view_state_owner.rb"
    ])

    source = state_install_generator_source
    expect(source).to include("create_tree_view_states.rb")
    expect(source).to include('db/migrate/#{migration_number}_create_tree_view_states.rb')
    expect(source).to include("app/models/tree_view_state.rb")
    expect(source).to include("app/models/concerns/tree_view_state_owner.rb")
  end
end
