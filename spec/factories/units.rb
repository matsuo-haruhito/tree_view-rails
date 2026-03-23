FactoryBot.define do
  factory :unit do
    association :machine
    sequence(:name) { |i| "ユニット#{i}" }
    parent_unit { nil }
  end
end
