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

  def run_generator(*args)
    described_class.start(args, destination_root: destination_root)
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

  it "includes the owner concern when an owner model is provided" do
    FileUtils.mkdir_p(File.join(destination_root, "app/models"))
    user_model = File.join(destination_root, "app/models/user.rb")
    File.write(user_model, <<~RUBY)
      class User < ApplicationRecord
      end
    RUBY

    run_generator("User")

    expect(File.read(user_model)).to include("class User < ApplicationRecord\n  include TreeViewStateOwner\nend")
  end

  it "includes the owner concern in a namespaced class-line owner model" do
    FileUtils.mkdir_p(File.join(destination_root, "app/models/admin"))
    admin_user_model = File.join(destination_root, "app/models/admin/user.rb")
    File.write(admin_user_model, <<~RUBY)
      class Admin::User < ApplicationRecord
      end
    RUBY

    run_generator("Admin::User")

    expect(File.read(admin_user_model)).to include("class Admin::User < ApplicationRecord\n  include TreeViewStateOwner\nend")
  end

  it "includes the owner concern in a module-wrapped namespaced owner model" do
    FileUtils.mkdir_p(File.join(destination_root, "app/models/admin"))
    admin_user_model = File.join(destination_root, "app/models/admin/user.rb")
    File.write(admin_user_model, <<~RUBY)
      module Admin
        class User < ApplicationRecord
        end
      end
    RUBY

    run_generator("Admin::User")

    expect(File.read(admin_user_model)).to include("  class User < ApplicationRecord\n    include TreeViewStateOwner\n  end")
  end

  it "does not duplicate the owner concern include" do
    FileUtils.mkdir_p(File.join(destination_root, "app/models"))
    user_model = File.join(destination_root, "app/models/user.rb")
    File.write(user_model, <<~RUBY)
      class User < ApplicationRecord
        include TreeViewStateOwner
      end
    RUBY

    run_generator("User")

    expect(File.read(user_model).scan("include TreeViewStateOwner").size).to eq(1)
  end

  it "skips owner concern injection when the owner model file does not exist" do
    expect { run_generator("User") }.not_to raise_error

    expect(File).not_to exist(File.join(destination_root, "app/models/user.rb"))
  end
end
