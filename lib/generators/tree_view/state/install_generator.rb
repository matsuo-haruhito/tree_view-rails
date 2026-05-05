# frozen_string_literal: true

require "rails/generators"

module TreeView
  module Generators
    module State
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        def copy_files
          template "create_tree_view_states.rb", migration_path
          template "tree_view_state.rb", "app/models/tree_view_state.rb"
          template "tree_view_state_owner.rb", "app/models/concerns/tree_view_state_owner.rb"
        end

        private

        def migration_path
          "db/migrate/#{migration_number}_create_tree_view_states.rb"
        end

        def migration_number
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        end
      end
    end
  end
end
