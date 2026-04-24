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
      ]
    end

    initializer "tree_view.importmap", after: "importmap" do |app|
      next unless app.config.respond_to?(:importmap)

      app.config.importmap.paths << root.join("config/importmap.tree_view.rb").to_s
    end

    initializer "tree_view.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper TreeViewHelper
      end
    end
  end
end
