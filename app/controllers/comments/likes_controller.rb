class Comments::LikesController < ApplicationController
  include Likable

  before_action :find_likable!

  private
  def find_likable!
    @likable = Comment.find_by(id: params[:comment_id]) if params[:comment_id]
  end
end