# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    title { FFaker::Lorem.sentence }
    body { FFaker::Lorem.paragraph }
    ip { FFaker::Internet.ip_v4_address }

    association :user, factory: :user
  end
end
