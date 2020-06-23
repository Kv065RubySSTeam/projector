# frozen_string_literal: true

module LikesHelper
  def liked_by?(likable)
    likable.likes.where(user: current_user).empty?
  end
end
