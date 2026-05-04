# frozen_string_literal: true

module TreeView
  module RenderStateBuilderValidation
    private

    def validate_builders!(builders)
      builders.each do |name, builder|
        validate_builder!(builder, name)
      end
    end
  end
end
