# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |i| "user#{i}" }
    sequence(:password) { |i| "password#{i}" }
    sequence(:name) { |i| "ユーザ#{i}" }
  end
end
