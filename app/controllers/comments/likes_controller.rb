# frozen_string_literal: true

class Comments::LikesController < ApplicationController
  include Likable

  private

  def find_likable!
    @likable = Comment.find(params[:comment_id])
  end
end
