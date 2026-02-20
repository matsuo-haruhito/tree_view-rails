FactoryBot.define do
  factory :item do
    sequence(:name) { |i| "item#{i}" }
    comment { 'comment' }
    parent_item_id { nil }
  end
end
