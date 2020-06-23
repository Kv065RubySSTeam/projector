# frozen_string_literal: true

module Likable
  extend ActiveSupport::Concern

  included do
    before_action :find_likable!
  end

  def create
    @like = @likable.likes.create(user: current_user)
    respond_to do |f|
      if @like.errors.empty?
        f.js { render action: 'change_button', status: 200 }
      else
        flash[:error] = @like.errors.full_messages.join("\n")
        f.js { render action: 'change_button', status: 422 }
      end
    end
  end

  def destroy
    @like = @likable.likes.find_by(user: current_user)
    respond_to do |f|
      if @like.destroy
        f.js { render action: 'change_button', status: 200 }
      else
        flash[:error] = @like.errors.full_messages.join("\n")
        f.js { render action: 'change_button', status: 422 }
      end
    end
  end
end
