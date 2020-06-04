require 'faker'

FactoryBot.define do
  factory :card do
    title { Faker::Name.name }
    sequence(:position)
    column
    user
  end
end
