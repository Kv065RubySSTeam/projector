class Emoji < ApplicationRecord
  belongs_to :user
  belongs_to :emojible, polymorphic: true
end
