require 'faker'

FactoryBot.define do
  factory :column do
    name { Faker::Lorem.sentence(word_count: 3, supplemental: true) }
    board
    user
    sequence(:position)

    factory :column_with_cards do
      transient do
        cards_count { 5 }
      end
      after(:create) do |column, evaluator|
        create_list(:card, evaluator.cards_count, column: column)
      end
    end

  end
end
