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

          updated = inject_owner_concern(content)
          if updated == content
            say_status :skip, "#{owner_path} class definition not found"
            return
          end

          File.write(owner_file, updated)
        end

        private

        def inject_owner_concern(content)
          owner_class_candidates.each do |class_name|
            pattern = /^(\s*)class #{Regexp.escape(class_name)}\b.*$/
            next unless content.match?(pattern)

            return content.sub(pattern) do |line|
              "#{line}\n#{Regexp.last_match(1)}  include TreeViewStateOwner"
            end
          end

          content
        end

        def owner_class_candidates
          [owner_model_name, owner_model_name.demodulize].uniq
        end

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
