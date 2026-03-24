FactoryBot.define do
  factory :material do
    association :part
    sequence(:name) { |i| "材料#{i}" }
  end
end
