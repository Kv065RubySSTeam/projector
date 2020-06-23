# frozen_string_literal: true

module Columns
  # Service that create column with {Column::DEFAULT_TITLE default title}
  # and automatically calculated position.
  class CreateService < ApplicationService
    # @return [Board] board on which the column will be created
    attr_accessor :board

    # @return [User] column creator
    attr_accessor :user

    def initialize(board, user)
      @board = board
      @user = user
    end

    # @note Column can be created only if user has permissions for column's board
    # Create a column with {Column::DEFAULT_TITLE default title}
    # and  {#calculate_new_column_postion automatically calculated position}
    # on the {CreateService#board} with {CreateService#user} as creator
    # @return [Column]
    def call
      board.columns.create(
        name: Column::DEFAULT_TITLE,
        position: calculate_new_column_postion,
        user: user
      )
    end

    private

    # Calculate position for new column
    # using last_column_position method on {CreateService#board} instance
    # @return [Integer] new column position
    def calculate_new_column_postion
      board.last_column_position.to_i + 1
    end
  end
end
