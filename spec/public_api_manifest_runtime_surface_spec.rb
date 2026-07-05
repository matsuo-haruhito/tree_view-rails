# frozen_string_literal: true

require "spec_helper"
require "generators/tree_view/state/install_generator"
require "yaml"

RSpec.describe "Public API manifest runtime surface" do
  def public_api_manifest
    @public_api_manifest ||= YAML.safe_load_file(File.expand_path("../config/public_api_manifest.yml", __dir__))
  end

  def render_state_source
    @render_state_source ||= File.read(File.expand_path("../lib/tree_view/render_state.rb", __dir__))
  end

  def state_install_generator_source
    @state_install_generator_source ||= File.read(File.expand_path("../lib/generators/tree_view/state/install_generator.rb", __dir__))
  end

  def keyword_names(callable, *parameter_types)
    callable.parameters.filter_map do |parameter_type, parameter_name|
      parameter_name.to_s if parameter_types.include?(parameter_type)
    end
  end

  def constantize(class_name)
    class_name.split("::").reduce(Object) { |namespace, constant_name| namespace.const_get(constant_name) }
  end

  it "keeps Ruby module, constant, and helper surfaces aligned with the manifest" do
    public_api_manifest.fetch("module_methods").each do |method_name|
      expect(TreeView).to respond_to(method_name.to_sym),
        "config/public_api_manifest.yml module_methods includes #{method_name}, but TreeView does not respond to it"
    end

    public_api_manifest.fetch("public_constants").each do |constant_name|
      expect(TreeView.const_defined?(constant_name)).to be(true),
        "config/public_api_manifest.yml public_constants includes #{constant_name}, but TreeView::#{constant_name} is missing"
    end

    public_api_manifest.fetch("helper_methods").each do |method_name|
      expect(TreeViewHelper.public_instance_methods).to include(method_name.to_sym),
        "config/public_api_manifest.yml helper_methods includes #{method_name}, but TreeViewHelper##{method_name} is missing"
    end
  end

  it "keeps RenderState callback builder keys aligned with source keywords and runtime readers" do
    manifest_keys = public_api_manifest.fetch("render_state_callback_builder_keys")
    public_readers = TreeView::RenderState.public_instance_methods

    expect(manifest_keys).to include(
      "row_class_builder",
      "row_data_builder",
      "row_event_payload_builder",
      "toggle_icon_builder"
    )

    missing_keywords = manifest_keys.reject { |key| render_state_source.include?("#{key}: nil") }
    expect(missing_keywords).to be_empty,
      "config/public_api_manifest.yml render_state_callback_builder_keys contains keys missing from TreeView::RenderState#initialize source keywords: #{missing_keywords}"

    missing_readers = manifest_keys.reject { |key| public_readers.include?(key.to_sym) }
    expect(missing_readers).to be_empty,
      "config/public_api_manifest.yml render_state_callback_builder_keys contains keys without public readers: #{missing_readers}"
  end

  it "keeps ResourceTableRenderState.call keyword surface aligned with the manifest" do
    manifest_surface = public_api_manifest.fetch("resource_table_render_state_call")
    call_method = TreeView::ResourceTableRenderState.method(:call)

    required_keywords = keyword_names(call_method, :keyreq)
    optional_keywords = keyword_names(call_method, :key)
    keyrest_name = call_method.parameters.find { |parameter_type, _| parameter_type == :keyrest }&.last&.to_s

    expect(manifest_surface.fetch("required_keywords")).to eq(required_keywords),
      "config/public_api_manifest.yml resource_table_render_state_call.required_keywords must match TreeView::ResourceTableRenderState.call required keywords"
    expect(manifest_surface.fetch("optional_keywords")).to eq(optional_keywords),
      "config/public_api_manifest.yml resource_table_render_state_call.optional_keywords must match TreeView::ResourceTableRenderState.call optional keywords"
    expect(manifest_surface.fetch("render_options_contract")).to eq("render_state_pass_through")
    expect(keyrest_name).to eq("render_options"),
      "TreeView::ResourceTableRenderState.call must keep **render_options for the manifest render_state_pass_through contract"
  end

  it "keeps Diagnostics manifest surface aligned with runtime" do
    manifest_surface = public_api_manifest.fetch("diagnostics")
    run_keywords = keyword_names(TreeView::Diagnostics.method(:run), :key)
    result_class = TreeView::Diagnostics::Result
    result_instance = result_class.new(checks: [], errors: [], warnings: [])

    expect(manifest_surface.fetch("accepted_checks")).to eq(TreeView::Diagnostics::DEFAULT_CHECKS.map(&:to_s)),
      "config/public_api_manifest.yml diagnostics.accepted_checks must match TreeView::Diagnostics::DEFAULT_CHECKS"

    missing_run_options = manifest_surface.fetch("run_options").reject { |keyword| run_keywords.include?(keyword) }
    expect(missing_run_options).to be_empty,
      "config/public_api_manifest.yml diagnostics.run_options contains keywords missing from TreeView::Diagnostics.run: #{missing_run_options}"

    expect(manifest_surface.fetch("result_surface").fetch("attributes")).to eq(result_class.members.map(&:to_s)),
      "config/public_api_manifest.yml diagnostics.result_surface.attributes must match TreeView::Diagnostics::Result members"

    missing_result_methods = manifest_surface.fetch("result_surface").fetch("methods").reject do |method_name|
      result_instance.respond_to?(method_name.to_sym)
    end
    expect(missing_result_methods).to be_empty,
      "config/public_api_manifest.yml diagnostics.result_surface.methods contains methods missing from TreeView::Diagnostics::Result: #{missing_result_methods}"
  end

  it "keeps persisted-state install generator manifest surface aligned with runtime and source templates" do
    manifest_surface = public_api_manifest.fetch("setup_generators").fetch("persisted_state_install")
    generator_source = state_install_generator_source

    expect(constantize(manifest_surface.fetch("class_name"))).to eq(TreeView::Generators::State::InstallGenerator),
      "config/public_api_manifest.yml setup_generators.persisted_state_install.class_name must resolve to the install generator class"

    manifest_surface.fetch("optional_arguments").each do |argument|
      expected_argument = "argument :#{argument.fetch("name")}, type: :string, required: false, banner: \"#{argument.fetch("banner")}\""
      expect(generator_source).to include(expected_argument),
        "config/public_api_manifest.yml setup_generators.persisted_state_install.optional_arguments includes #{argument}, but the install generator source does not expose the same optional argument"
    end

    expect(manifest_surface.fetch("generated_paths")).to eq([
      "db/migrate/*_create_tree_view_states.rb",
      "app/models/tree_view_state.rb",
      "app/models/concerns/tree_view_state_owner.rb"
    ])

    expect(generator_source).to include("template \"create_tree_view_states.rb\", migration_path"),
      "config/public_api_manifest.yml setup_generators.persisted_state_install.generated_paths must stay aligned with the migration template"
    expect(generator_source).to include("template \"tree_view_state.rb\", \"app/models/tree_view_state.rb\""),
      "config/public_api_manifest.yml setup_generators.persisted_state_install.generated_paths must stay aligned with tree_view_state.rb"
    expect(generator_source).to include("template \"tree_view_state_owner.rb\", \"app/models/concerns/tree_view_state_owner.rb\""),
      "config/public_api_manifest.yml setup_generators.persisted_state_install.generated_paths must stay aligned with tree_view_state_owner.rb"
    expect(generator_source).to include('"db/migrate/#{migration_number}_create_tree_view_states.rb"'),
      "config/public_api_manifest.yml setup_generators.persisted_state_install.generated_paths must stay aligned with the migration_path runtime pattern"
  end
end
