require 'faker'

FactoryBot.define do
  factory :card do
    title { "title" }
    body { "blah" }
    user { create(:user) }
    column { create(:column) }
    sequence(:position)
  end
end