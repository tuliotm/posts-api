# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    value { rand(1..5) }

    association :user, factory: :user
    association :post, factory: :post
  end
end
