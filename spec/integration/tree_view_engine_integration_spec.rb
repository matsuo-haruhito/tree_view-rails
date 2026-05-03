require "spec_helper"
require "action_controller/railtie"
require "tree_view/engine"

RSpec.describe TreeView::Engine do
  let(:engine) { described_class.instance }
  let(:helper_initializer) { engine.initializers.find { |initializer| initializer.name == "tree_view.helpers" } }

  def assets_initializer
    engine.initializers.find { |initializer| initializer.name == "tree_view.assets" }
  end

  def importmap_initializer
    engine.initializers.find { |initializer| initializer.name == "tree_view.importmap" }
  end

  it "registers TreeViewHelper on ActionController::Base via engine initializer" do
    helper_initializer.run(Object.new)

    expect(ActionController::Base._helpers.included_modules).to include(TreeViewHelper)
  end

  it "adds importmap path when importmap config is available" do
    config = Struct.new(:importmap).new(Struct.new(:paths).new([]))
    app = Struct.new(:config).new(config)
    expected_path = TreeView::Engine.root.join("config/importmap.tree_view.rb").to_s

    importmap_initializer.run(app)

    expect(app.config.importmap.paths).to include(expected_path)
  end

  it "adds javascript assets path and precompile targets when assets config is available" do
    assets = Struct.new(:paths, :precompile).new([], [])
    config = Struct.new(:assets).new(assets)
    app = Struct.new(:config).new(config)
    expected_path = TreeView::Engine.root.join("app/javascript")

    assets_initializer.run(app)

    expect(app.config.assets.paths).to include(expected_path)
    expect(app.config.assets.precompile).to include("tree_view.css", "tree_view/index.js")
  end

  it "skips importmap hook safely when importmap config is unavailable" do
    app = Struct.new(:config).new(Struct.new(:assets).new(nil))

    expect do
      importmap_initializer.run(app)
    end.not_to raise_error
  end

  it "skips assets hook safely when assets config is unavailable" do
    app = Struct.new(:config).new(Object.new)

    expect do
      assets_initializer.run(app)
    end.not_to raise_error
  end
end
