FactoryBot.define do
  factory :comment do
    body { "blah" }
    user { create(:user)}
    card { create(:card)}
  end
end