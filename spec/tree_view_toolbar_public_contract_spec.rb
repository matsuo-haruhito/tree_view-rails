# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "TreeView toolbar public contract" do
  MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
  TOOLBAR_DOC_PATHS = [
    File.expand_path("../docs/en/toolbar.md", __dir__),
    File.expand_path("../docs/ja/toolbar.md", __dir__)
  ].freeze

  def toolbar_manifest_actions
    YAML.safe_load_file(MANIFEST_PATH).fetch("toolbar_actions")
  end

  def toolbar_helper
    Class.new do
      include TreeViewHelper
    end.new
  end

  def render_state_for_toolbar
    ui_config = Struct.new(:calls) do
      def toggle_all_path(state:)
        calls << state
        "/tree?state=#{state}"
      end
    end.new([])

    Struct.new(:ui_config).new(ui_config)
  end

  def stringified_toolbar_states
    TreeViewHelper::Toolbar::TREE_VIEW_TOOLBAR_STATES.to_h do |action, state|
      [action.to_s, state.to_s]
    end
  end

  it "keeps toolbar action names and toggle states aligned with the public API manifest" do
    manifest_actions = toolbar_manifest_actions

    expect(stringified_toolbar_states).to eq(manifest_actions)
    expect(toolbar_helper.tree_view_toolbar_supported_actions.map(&:to_s)).to eq(manifest_actions.keys)
  end

  it "keeps toolbar metadata state values aligned with the manifest" do
    render_state = render_state_for_toolbar
    actions = toolbar_helper.tree_view_toolbar_actions(
      render_state,
      actions: toolbar_manifest_actions.keys
    )

    expect(actions.map { |action| [action.fetch(:action).to_s, action.fetch(:state).to_s] }.to_h).to eq(toolbar_manifest_actions)
    expect(actions).to all(include(path: a_string_matching(%r{\A/tree\?state=})))
  end

  it "keeps toolbar docs aligned with manifest action and state values" do
    manifest_actions = toolbar_manifest_actions

    TOOLBAR_DOC_PATHS.each do |path|
      docs = File.read(path)

      manifest_actions.each do |action, state|
        expect(docs).to include(":#{action}"), "expected #{path} to document toolbar action #{action}"
        expect(docs).to include(":#{state}"), "expected #{path} to document toolbar state #{state}"
      end
    end
  end
end
