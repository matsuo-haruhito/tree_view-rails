# frozen_string_literal: true

require "rails/engine"

module TreeView
  class Engine < ::Rails::Engine
    initializer "tree_view.assets" do |app|
      next unless app.config.respond_to?(:assets)

      app.config.assets.paths << root.join("app/javascript")
      app.config.assets.precompile += %w[
        tree_view.css
        tree_view/index.js
        tree_view/controllers/tree_context_menu_controller.js
      ]
    end

    initializer "tree_view.importmap", after: "importmap" do |app|
      next unless app.config.respond_to?(:importmap)

      app.config.importmap.paths << root.join("config/importmap.tree_view.rb").to_s
    end
  end
end
