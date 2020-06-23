# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likable, polymorphic: true
  validates_uniqueness_of :user_id, scope: :likable, presence: true
end
