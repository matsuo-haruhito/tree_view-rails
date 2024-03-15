# frozen_string_literal: true

module IncludesSerializer
  extend ActiveSupport::Concern

  included do
    # ActiveModelSerializers の include と同じ形式で includes する
    scope :includes_serializer, lambda { |param|
      includes(JSONAPI::IncludeDirective.new(param).to_hash)
    }
  end
end
