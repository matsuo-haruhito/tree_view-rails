# frozen_string_literal: true

require "spec_helper"
require "yaml"

PublicApiCompatibilityTestNode = Struct.new(:id, :parent_id, :name, keyword_init: true)
PUBLIC_API_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
JAVASCRIPT_ENTRYPOINT_PATH = File.expand_path("../app/javascript/tree_view/index.js", __dir__)
JAVASCRIPT_CONTROLLER_PATHS = {
  "state" => File.expand_path("../app/javascript/tree_view/state_controller.js", __dir__),
  "selection" => File.expand_path("../app/javascript/tree_view/selection_controller.js", __dir__),
  "remote_state" => File.expand_path("../app/javascript/tree_view/remote_state_controller.js", __dir__),
  "transfer" => File.expand_path("../app/javascript/tree_view/transfer_controller.js", __dir__)
}.freeze
RENDER_STATE_GROUPED_OPTION_KEY_RESOLVERS = {
  "initial_expansion" => -> { TreeView::RenderState::VALID_INITIAL_EXPANSION_KEYS.map(&:to_s) },
  "render_scope" => -> { TreeView::RenderState::VALID_RENDER_SCOPE_KEYS.map(&:to_s) },
  "toggle_scope" => -> { TreeView::RenderState::VALID_TOGGLE_SCOPE_KEYS.map(&:to_s) },
  "selection" => -> { TreeView::RenderState::SelectionConfig::VALID_KEYS.map(&:to_s) },
  "lazy_loading" => -> { %w[enabled loaded_keys scope] },
  "row_status" => -> { %w[row_disabled_builder row_readonly_builder row_disabled_reason_builder] }
}.freeze

RSpec.describe "Public API compatibility" do
  def public_api_manifest
    # The machine-readable manifest covers Ruby/module/helper entrypoints,
    # grouped option keys, package-root exports, and required JavaScript event
    # detail keys. Broader behavior and docs sync stay explicit here.
    @public_api_manifest ||= YAML.safe_load_file(PUBLIC_API_MANIFEST_PATH)
  end

  def public_javascript_manifest
    public_api_manifest.fetch("javascript_package_root")
  end

  def public_javascript_event_names
    public_javascript_manifest.fetch("event_names")
  end

  def public_javascript_event_detail_keys
    public_javascript_manifest.fetch("event_detail_keys")
  end

  def javascript_entrypoint_source
    @javascript_entrypoint_source ||= File.read(JAVASCRIPT_ENTRYPOINT_PATH)
  end

  def javascript_controller_source(group_name)
    @javascript_controller_sources ||= {}
    @javascript_controller_sources[group_name] ||= File.read(JAVASCRIPT_CONTROLLER_PATHS.fetch(group_name))
  end

  def camelize_manifest_key(value)
    value.to_s.gsub(/_([a-z])/) { Regexp.last_match(1).upcase }
  end

  def event_names_by_export_group
    public_javascript_event_names.transform_keys { |group_name| camelize_manifest_key(group_name) }
  end

  def event_dispatch_name(event_key)
    event_key.tr("_", "-")
  end

  def source_dispatches_event?(source, dispatch_name)
    source.match?(/\b(?:dispatch|dispatch[A-Za-z]*)\("#{Regexp.escape(dispatch_name)}"/)
  end

  def source_dispatch_windows(source, dispatch_name)
    matcher = /\b(?:dispatch|dispatch[A-Za-z]*)\("#{Regexp.escape(dispatch_name)}"/

    source.to_enum(:scan, matcher).map do
      start_index = Regexp.last_match.begin(0)
      end_index = source.index(/\n  }\n/, start_index) || source.length

      source[start_index...end_index]
    end
  end

  def source_mentions_detail_key?(source, detail_key)
    source.match?(/#{Regexp.escape(detail_key)}\s*:/) || source.match?(/(?:^|[\s,{])#{Regexp.escape(detail_key)}(?:$|[\s,}])/)
  end

  def source_mentions_shorthand_detail?(source)
    source.match?(/detail\s*[},]/)
  end

  def source_mentions_detail_key_for_dispatch?(source, dispatch_name, detail_key)
    source_dispatch_windows(source, dispatch_name).any? do |dispatch_source|
      source_mentions_detail_key?(dispatch_source, detail_key) ||
        (source_mentions_shorthand_detail?(dispatch_source) && source_mentions_detail_key?(source, detail_key))
    end
  end

  def dom_id_suffix(item_or_id)
    return item_or_id.id if item_or_id.respond_to?(:id)

    item_or_id
  end

  def public_ui_config
    TreeView::UiConfig.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{dom_id_suffix(item_or_id)}" },
      button_dom_id_builder: ->(item_or_id) { "node_button_#{dom_id_suffix(item_or_id)}" },
      show_button_dom_id_builder: ->(item_or_id) { "node_show_button_#{dom_id_suffix(item_or_id)}" }
    )
  end

  def public_tree
    root = PublicApiCompatibilityTestNode.new(id: 1, parent_id: nil, name: "Root")
    child = PublicApiCompatibilityTestNode.new(id: 2, parent_id: 1, name: "Child")

    TreeView::Tree.new(records: [root, child], parent_id_method: :parent_id)
  end

  it "keeps documented TreeView module methods available" do
    public_api_manifest.fetch("module_methods").each do |method_name|
      expect(TreeView).to respond_to(method_name.to_sym), "expected TreeView.#{method_name} to remain public"
    end

    expect(TreeView.node_key(:document, 1)).to eq("document:1")
  end

  it "keeps documented configuration options available" do
    expect(TreeView.configuration.initial_state).to eq(:expanded)
    expect(TreeView.configuration.render_log_level).to eq(:warn)

    TreeView.configure do |config|
      config.initial_state = :collapsed
      config.render_log_level = :info
    end

    expect(TreeView.configuration.initial_state).to eq(:collapsed)
    expect(TreeView.configuration.render_log_level).to eq(:info)

    configuration = TreeView::Configuration.new(initial_state: "expanded", render_log_level: Logger::ERROR)
    expect(configuration.initial_state).to eq(:expanded)
    expect(configuration.render_log_level).to eq(:error)

    configuration.initial_state = :collapsed
    configuration.render_log_level = nil
    expect(configuration.initial_state).to eq(:collapsed)
    expect(configuration.render_log_level).to be_nil
  end

  it "keeps documented public Ruby constants available" do
    public_api_manifest.fetch("public_constants").each do |constant_name|
      expect(TreeView.const_defined?(constant_name)).to be(true), "expected TreeView::#{constant_name} to remain public"
    end
  end

  it "keeps documented UiConfigBuilder mode methods available" do
    builder = TreeView::UiConfigBuilder.new(context: Object.new)

    expect(builder).to respond_to(:build)
    expect(builder).to respond_to(:build_turbo)
    expect(builder).to respond_to(:build_static)
    expect(builder).to respond_to(:build_client_side)
  end

  it "keeps documented RenderState grouped option keys available" do
    public_api_manifest.fetch("grouped_option_keys").each do |group_name, manifest_keys|
      expected_keys = RENDER_STATE_GROUPED_OPTION_KEY_RESOLVERS.fetch(group_name).call

      expect(manifest_keys).to eq(expected_keys), "expected #{group_name} keys to match the documented public grouped option contract"
    end
  end

  it "keeps representative grouped option behavior available" do
    tree = instance_double(TreeView::Tree)
    ui_config = instance_double(TreeView::UiConfig)
    row_disabled_builder = ->(item) { item == :disabled }
    row_readonly_builder = ->(item) { item == :readonly }
    row_disabled_reason_builder = ->(item) { (item == :disabled) ? "archived" : nil }

    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      initial_expansion: {
        default: :collapsed,
        max_depth: 2,
        expanded_keys: ["node:1"],
        collapsed_keys: ["node:2"],
        current_key: "node:3",
        auto_expand_ancestors: false
      },
      render_scope: {
        max_depth: 3,
        max_leaf_distance: 1
      },
      toggle_scope: {
        max_depth_from_root: 4,
        max_leaf_distance: 2
      },
      selection: {
        enabled: true,
        visibility: :leaves,
        checkbox_name: "selected_documents[]",
        selected_keys: ["node:3"],
        cascade: true,
        indeterminate: true,
        max_count: 5
      },
      lazy_loading: {
        enabled: true,
        loaded_keys: ["node:1"],
        scope: "children"
      },
      row_disabled_builder: row_disabled_builder,
      row_readonly_builder: row_readonly_builder,
      row_disabled_reason_builder: row_disabled_reason_builder
    )

    expect(state.initial_state).to eq(:collapsed)
    expect(state.max_initial_depth).to eq(2)
    expect(state.expanded_keys).to eq(["node:1"])
    expect(state.collapsed_keys).to eq(["node:2"])
    expect(state.current_key).to eq("node:3")
    expect(state.auto_expand_ancestors?).to eq(false)
    expect(state.max_render_depth).to eq(3)
    expect(state.max_leaf_distance).to eq(1)
    expect(state.max_toggle_depth_from_root).to eq(4)
    expect(state.max_toggle_leaf_distance).to eq(2)
    expect(state.selection_enabled?).to eq(true)
    expect(state.selection_visibility).to eq(:leaves)
    expect(state.selection_checkbox_name).to eq("selected_documents[]")
    expect(state.selection_selected_keys).to eq(["node:3"])
    expect(state.selection_cascade?).to eq(true)
    expect(state.selection_indeterminate?).to eq(true)
    expect(state.selection_max_count).to eq(5)
    expect(state.lazy_loading_enabled?).to eq(true)
    expect(state.lazy_loading_loaded_keys).to eq(["node:1"])
    expect(state.lazy_loading_scope).to eq("children")
    expect(state.row_disabled_builder).to eq(row_disabled_builder)
    expect(state.row_readonly_builder).to eq(row_readonly_builder)
    expect(state.row_disabled_reason_builder).to eq(row_disabled_reason_builder)
  end

  it "keeps documented helper method names available through TreeViewHelper" do
    public_api_manifest.fetch("helper_methods").each do |method_name|
      expect(TreeViewHelper.public_instance_methods).to include(method_name.to_sym), "expected TreeViewHelper##{method_name} to remain public"
    end
  end

  it "keeps documented lazy-loading helper behavior available through TreeViewHelper" do
    helper_class = Class.new do
      include TreeViewHelper

      attr_accessor :tree_ui
    end

    item = PublicApiCompatibilityTestNode.new(id: 1, parent_id: nil, name: "Root")
    helper = helper_class.new
    helper.tree_ui = public_ui_config

    expect(helper.tree_children_container_dom_id(item)).to eq("node_1_children")
    expect(helper.tree_remote_state_placeholder_dom_id(item)).to eq("node_1_remote_state")
    expect(helper.tree_remote_state_placeholder_attributes(item)).to eq({id: "node_1_remote_state"})
    expect(helper.tree_remote_state_placeholder_attributes(item, state: :loading)).to eq({
      id: "node_1_remote_state",
      data: {tree_remote_state: "loading"}
    })
  end

  it "keeps lazy-loading state actions aligned with host lifecycle manifest events" do
    helper_class = Class.new do
      include TreeViewHelper

      attr_accessor :tree_ui
    end

    item = PublicApiCompatibilityTestNode.new(id: 1, parent_id: nil, name: "Root")
    helper = helper_class.new
    helper.tree_ui = public_ui_config

    loaded_actions = helper.tree_remote_state_placeholder_attributes(item, state: :loaded)[:data]
    loading_actions = helper.tree_remote_state_placeholder_attributes(item, state: :loading)[:data]
    error_actions = helper.tree_remote_state_placeholder_attributes(item, state: :error, retry_url: "/retry")[:data]

    expect(loaded_actions[:action]).to include("tree-view:loaded@window->tree-view-remote-state#syncLoaded")
    expect(loading_actions[:action]).to include("tree-view:loading@window->tree-view-remote-state#syncLoading")
    expect(error_actions[:action]).to include("tree-view:error@window->tree-view-remote-state#syncError")
    expect(error_actions[:action]).to include("tree-view:retry@window->tree-view-remote-state#syncRetry")
  end

  it "keeps windowed rendering helper behavior available through TreeViewHelper" do
    helper_class = Class.new do
      include TreeViewHelper

      attr_accessor :tree_ui
    end

    item = PublicApiCompatibilityTestNode.new(id: 1, parent_id: nil, name: "Root")
    helper = helper_class.new
    helper.tree_ui = public_ui_config

    expect(helper.tree_view_window(public_tree.render_state(root_items: public_tree.roots), offset: 0, limit: 10)).to eq({
      offset: 0,
      limit: 10,
      total: 2,
      has_more: false
    })
  end

  it "keeps supported toolbar actions aligned with the public API manifest" do
    manifest_actions = public_api_manifest.fetch("toolbar_actions")

    expect(TreeViewHelper::Toolbar::ACTIONS.keys.map(&:to_s)).to match_array(manifest_actions.keys)
    manifest_actions.each do |action_name, expected_state|
      expect(TreeViewHelper::Toolbar::ACTIONS.fetch(action_name.to_sym).fetch(:state).to_s).to eq(expected_state)
    end
  end

  it "keeps documented toolbar helper behavior available through TreeViewHelper" do
    helper_class = Class.new do
      include TreeViewHelper

      attr_accessor :tree_ui
    end

    helper = helper_class.new
    helper.tree_ui = public_ui_config

    tree = public_tree
    render_state = tree.render_state(root_items: tree.roots)

    expect(helper.tree_view_toolbar_supported_actions).to include(:expand_all, :collapse_all, :collapse_all_except_current_path)
    expect(helper.tree_view_toolbar_actions(render_state)).to all(include(:key, :label, :state, :disabled, :html_options))
    expect(helper.tree_view_toolbar_actions(render_state, labels: { expand_all: "Open all" }).to include(include(label: "Open all"))
    expect(helper.tree_view_toolbar_action_metadata(render_state, :expand_all)).to include(key: :expand_all, state: :expanded, disabled: false)
  end

  it "keeps bundled package root exports available" do
    public_javascript_manifest.fetch("named_exports").each do |export_name|
      expect(javascript_entrypoint_source).to include("export")
      expect(javascript_entrypoint_source).to include(export_name)
    end
  end

  it "keeps controller identifiers aligned with the public JavaScript manifest" do
    identifier_exports = public_javascript_manifest.fetch("controller_registrations")
    root_export_names = identifier_exports.map { |entry| entry.fetch("export") }

    root_export_names.each do |export_name|
      expect(javascript_entrypoint_source).to include(export_name)
    end

    identifiers_source = javascript_entrypoint_source[/TreeViewControllerIdentifiers = \{.*?\n\}/m]

    identifier_exports.each do |entry|
      controller_key = entry.fetch("key")
      identifier = entry.fetch("identifier")

      expect(identifiers_source).to include("#{controller_key}: \"#{identifier}\"")
    end
  end

  it "keeps event names aligned with the public JavaScript manifest" do
    exported_source = javascript_entrypoint_source[/TreeViewEventNames = \{.*?\n\}/m]

    event_names_by_export_group.each do |export_group, events|
      events.each do |event_key, event_name|
        expect(exported_source).to include("#{camelize_manifest_key(event_key)}: \"#{event_name}\"")
        expect(exported_source).to include("#{export_group}: {")
      end
    end
  end

  it "keeps documented controller dispatches aligned with event names" do
    public_javascript_event_names.each do |group_name, events|
      controller_source = javascript_controller_source(group_name)

      events.each do |event_key, event_name|
        dispatch_name = event_dispatch_name(event_key)

        expect(controller_source).to include(event_name)
        expect(source_dispatches_event?(controller_source, dispatch_name)).to be(true), "expected #{group_name} controller to dispatch #{dispatch_name}"
      end
    end
  end

  it "keeps documented controller event detail keys aligned with dispatch payloads" do
    public_javascript_event_detail_keys.each do |group_name, events|
      controller_source = javascript_controller_source(group_name)

      events.each do |event_key, detail_keys|
        dispatch_name = event_dispatch_name(event_key)

        detail_keys.each do |detail_key|
          expect(source_mentions_detail_key_for_dispatch?(controller_source, dispatch_name, detail_key)).to be(true), "expected #{group_name} #{event_key} dispatch to include #{detail_key}"
        end
      end
    end
  end
end
