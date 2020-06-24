# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  before_action do
    @notificationable = params[:notificationable]
    @user = params[:user]
  end
  before_action :assign_card
  before_action :assign_board

  def add_assignee_notification
    send_mail("New user was tagged as a assignee at the card \"#{@notificationable.title}\"")
  end

  def add_comment_notification
    send_mail("New comment added to the \"#{@notificationable.card.title}\"")
  end

  def move_card_notification
    send_mail("Card \"#{@notificationable.title}\" was moved to another column")
  end

  def destroy_card_notification
    send_mail("Card \"#{@notificationable.title}\" has been deleted from \"#{@board.title}\"")
  end

  private

  def send_mail(subject)
    mail(to: @user.email, subject: subject)
  end

  def assign_card
    @card = if @notificationable.is_a?(Comment)
              @notificationable.card
            else
              @notificationable
            end
  end

  def assign_board
    @board = @card.column.board
  end
end
