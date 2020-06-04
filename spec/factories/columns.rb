require 'faker'

FactoryBot.define do
  factory :column do
    name { Faker::Name.name }
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
