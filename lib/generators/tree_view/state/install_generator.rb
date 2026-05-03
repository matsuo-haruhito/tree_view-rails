# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module TreeView
  module Generators
    module State
      class InstallGenerator < Rails::Generators::Base
        include ActiveRecord::Generators::Migration

        source_root File.expand_path("templates", __dir__)

        def self.next_migration_number(dirname)
          ActiveRecord::Generators::Base.next_migration_number(dirname)
        end

        def copy_files
          migration_template "create_tree_view_states.rb", "db/migrate/create_tree_view_states.rb"
          template "tree_view_state.rb", "app/models/tree_view_state.rb"
          template "tree_view_state_owner.rb", "app/models/concerns/tree_view_state_owner.rb"
        end
      end
    end
  end
end
