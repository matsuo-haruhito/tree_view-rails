FactoryBot.define do
  factory :machine do
    sequence(:name) { |i| "機械#{i}" }
    parent_machine { nil }
  end
end
