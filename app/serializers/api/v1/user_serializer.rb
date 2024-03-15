# frozen_string_literal: true

class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :username,
    :name,
    :furigana,
    :admin
  )
end
