module Boards
  class CreateService < ApplicationService
    attr_accessor :board_params, :user

    def initialize(user, board_params)
      @board_params, @user = board_params, user
    end

    def call
      ActiveRecord::Base.transaction do
        board = Board.create!(board_params.merge user: user)
        board.memberships.create!(admin: true, user: user)
        return board
      rescue ActiveRecord::RecordInvalid => e
        return e.record 
      end
    end
  end
end
