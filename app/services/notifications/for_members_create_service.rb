module Notifications
  class ForMembersCreateService < Notifications::CreateService
    attr_accessor :board

    def initialize(notification_type, card, board)
      super(notification_type, card)
      @board = board
    end

    private

    def send_email
      board.users.each do |user|
        CardMailer.with(card: card, user: user, board: board)
                                        .send(notification_type.to_sym)
                                        .deliver_later if user.receive_emails
      end
    end
  end
end
