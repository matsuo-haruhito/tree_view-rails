# frozen_string_literal: true

require "rails/generators"

module TreeView
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Shows TreeView installation steps for a Rails host application."

      def show_installation_steps
        say "TreeView installation", :green
        say ""
        say "1. Import the TreeView stylesheet from your application stylesheet:"
        say "   @import \"tree_view\";"
        say ""
        say "2. Load the TreeView importmap pins from config/importmap.rb if you use importmap-rails:"
        say "   Rails.application.config.importmap.paths << TreeView::Engine.root.join(\"config/importmap.tree_view.rb\")"
        say ""
        say "3. Register the Stimulus controllers from tree_view/index.js when you use the JavaScript helpers."
        say ""
        say "4. Create a host app row partial and pass it as row_partial to TreeView::RenderState."
      end
    end
  end
end
