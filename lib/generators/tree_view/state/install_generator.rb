# frozen_string_literal: true

require "rails/generators"

module TreeView
  module Generators
    module State
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        argument :owner_model_name, type: :string, required: false, banner: "OWNER_MODEL"

        def copy_files
          template "create_tree_view_states.rb", migration_path
          template "tree_view_state.rb", "app/models/tree_view_state.rb"
          template "tree_view_state_owner.rb", "app/models/concerns/tree_view_state_owner.rb"
        end

        def add_owner_concern
          return if owner_model_name.to_s.strip.empty?

          owner_path = File.join("app/models", "#{owner_model_name.underscore}.rb")
          owner_file = File.join(destination_root, owner_path)
          unless File.exist?(owner_file)
            say_status :skip, "#{owner_path} does not exist"
            return
          end

          content = File.read(owner_file)
          return if content.include?("include TreeViewStateOwner")

          updated = content.sub(/^class #{Regexp.escape(owner_model_name)}\b.*$/, "\\0\n  include TreeViewStateOwner")
          File.write(owner_file, updated)
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
