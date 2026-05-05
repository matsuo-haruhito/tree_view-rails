# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "generators/tree_view/state/install_generator"

RSpec.describe TreeView::Generators::State::InstallGenerator do
  let(:destination_root) { Dir.mktmpdir("tree_view_generator") }

  after do
    FileUtils.rm_rf(destination_root) if File.directory?(destination_root)
  end

  def run_generator
    described_class.start([], destination_root: destination_root)
  end

  it "creates persisted state migration, model, and owner concern" do
    run_generator

    migration = Dir[File.join(destination_root, "db/migrate/*_create_tree_view_states.rb")].first

    expect(migration).not_to be_nil
    expect(File.read(migration)).to include("create_table :tree_view_states")
    expect(File.read(migration)).to include("t.references :owner, polymorphic: true, null: false")
    expect(File.read(migration)).to include("t.string :tree_instance_key, null: false")
    expect(File.read(migration)).to include("t.json :expanded_keys, null: false, default: []")
    expect(File.read(migration)).to include("add_index :tree_view_states, [:owner_type, :owner_id, :tree_instance_key], unique: true")

    model = File.join(destination_root, "app/models/tree_view_state.rb")
    expect(File.read(model)).to include("class TreeViewState < ApplicationRecord")
    expect(File.read(model)).to include("belongs_to :owner, polymorphic: true")
    expect(File.read(model)).to include("validates :tree_instance_key, presence: true")

    concern = File.join(destination_root, "app/models/concerns/tree_view_state_owner.rb")
    expect(File.read(concern)).to include("module TreeViewStateOwner")
    expect(File.read(concern)).to include("has_many :tree_view_states, as: :owner, dependent: :destroy")
    expect(File.read(concern)).to include("def tree_view_state_for(tree_instance_key)")
    expect(File.read(concern)).to include("def save_tree_view_state!(tree_instance_key, expanded_keys:)")
    expect(File.read(concern)).to include("TreeView::PersistedState.new")
  end
end
