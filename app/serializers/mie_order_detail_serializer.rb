# frozen_string_literal: true

class MieOrderDetailSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :order_id,
    :standard,
    :wire_diameter,
    :tolerance,
    :specification,
    :weight,
    :unit,
    :quantity,
    :deadline,
    :remarks
  )
end
