# frozen_string_literal: true

class CardMailer < ApplicationMailer
  before_action do
    @card = params[:card]
    @user = params[:user]
  end

  def start_date_notify
    @board = @card.column.board
    @assignee = @card.assignee
    mail(to: @user.email, subject: "Card \"#{@card.title}\" planed for today.")
  end
end
