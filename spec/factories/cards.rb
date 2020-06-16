FactoryBot.define do
  factory :card do
    title { Faker::Lorem.sentence(word_count: 3, supplemental: true) }
    user
    column
    sequence(:position)
    association :assignee, factory: :user

    after(:create) do |card, evaluator|
      card.body.body= "<b>body</b>"
    end

    after(:create) do |card|
      card.audits.first.update(user: card.user)
    end

    trait :with_tags do
      tag_list { ["jogging", "diving", "swimming"] }
    end

    factory :card_with_comments do
      transient do
        comments_count { 3 }
      end

      after(:create) do |card, evaluator|
        create_list(:comment, evaluator.comments_count, card: card)
      end
    end
  end
end