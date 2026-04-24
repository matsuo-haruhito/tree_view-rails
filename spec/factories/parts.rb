FactoryBot.define do
  factory :part do
    association :machine
    unit { nil }
    sequence(:name) { |i| "部品#{i}" }
  end
end
