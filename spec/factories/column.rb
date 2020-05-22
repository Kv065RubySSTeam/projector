FactoryBot.define do
  factory :column do
    name { "#{Faker::Lorem.sentence(word_count: 3, supplemental: true)}" }
    user
    board
    sequence(:position)
  end
end