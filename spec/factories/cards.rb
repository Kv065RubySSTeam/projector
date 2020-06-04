require 'faker'

FactoryBot.define do
  factory :card do
    title { Faker::Name.name }
    user 
    column 
    sequence(:position)
  end
end
