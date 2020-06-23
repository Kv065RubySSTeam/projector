# frozen_string_literal: true

module Boards
  # Service that accepts +board_params+ and +user+ and instance method call returns new board
  class CreateService < ApplicationService
    # @!attribute [rw] board_params
    #   @return [Hash] params from the form to create new board
    # @!attribute [rw] user
    #   @return [User] user that creates board
    attr_accessor :board_params, :user

    # Sets initial values of new CreateService object
    # @param [User] user the user that creates board
    # @param [Hash] board_params the params from the form to create new board
    # @return [CreateService] new instance of the service
    def initialize(user, board_params)
      @board_params = board_params
      @user = user
    end

    # Adds +user+ params to +board_params+ hash and returns board and admin membership.
    # @return [Board] created board or invalid board object
    def call
      ActiveRecord::Base.transaction do
        board = Board.create!(board_params.merge(user: user))
        board.memberships.create!(admin: true, user: user)
        board
      rescue ActiveRecord::RecordInvalid => e
        e.record
      end
    end
  end
end
