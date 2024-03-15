# frozen_string_literal: true

class OrderSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :number,
    :deadline,
    :model,
    :product_number,
    :destination_name,
    :destination_address,
    :destination_phone_number,
    :construction_date,
    :contractor,
    :assignee,
    :plant_id
  )

  has_many :mie_details
  has_many :osaka_details
  belongs_to :plant
end
