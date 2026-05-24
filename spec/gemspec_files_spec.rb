# frozen_string_literal: true

require "spec_helper"

RSpec.describe "packaged gem files" do
  subject(:files) { Gem::Specification.load("tree_view.gemspec").files }

  let(:entrypoint_controller_files) do
    %w[
      app/javascript/tree_view/client_controller.js
      app/javascript/tree_view/remote_state_controller.js
      app/javascript/tree_view/selection_controller.js
      app/javascript/tree_view/state_controller.js
      app/javascript/tree_view/transfer_controller.js
    ]
  end

  it "includes runtime files required by Rails integration" do
    expect(files).to include(
      "lib/tree_view.rb",
      "lib/tree_view/engine.rb",
      "app/helpers/tree_view_helper.rb",
      "app/views/tree_view/_tree_row.html.erb",
      "app/views/tree_view/_tree_children.html.erb",
      "app/views/tree_view/_tree_toggle_cell.html.erb",
      "app/views/tree_view/_tree_toggle_content.html.erb",
      "app/views/tree_view/_tree_toggle_content_static.html.erb",
      "app/views/tree_view/_tree_toggle_content_turbo.html.erb",
      "app/views/tree_view/_tree_selection_cell.html.erb",
      "app/assets/stylesheets/tree_view.scss",
      "app/javascript/tree_view/index.js",
      "config/importmap.tree_view.rb"
    )
  end

  it "includes JavaScript controllers referenced by the packaged entrypoint" do
    expect(files).to include(*entrypoint_controller_files)
  end

  it "includes user-facing documentation and metadata" do
    expect(files).to include(
      "README.md",
      "CHANGELOG.md",
      "tree_view.gemspec"
    )
    expect(files.grep(/\ALICENSE/)).not_to be_empty
    expect(files.grep(%r{\Adocs/})).not_to be_empty
  end

  it "excludes development-only files" do
    expect(files).not_to include(
      ".rspec",
      "Gemfile",
      "Rakefile"
    )
    expect(files.grep(%r{\Aspec/})).to be_empty
  end
end
