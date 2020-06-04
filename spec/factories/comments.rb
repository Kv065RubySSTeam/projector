require 'faker'

FactoryBot.define do
  factory :comment do
    body { Faker::Name.name }
    user
    card
  end
end
