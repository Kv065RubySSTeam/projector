module Columns
  class CreateService < ApplicationService
    attr_accessor :board, :user

    def initialize(board, user)
      @board, @user = board, user
    end

    def call
      column = board.columns.build(
        name: Column::DEFAULT_TITLE,
        position: calculate_new_column_postion,
        user: user
      )
    end
    
    private
    def calculate_new_column_postion
      board.last_column_position.to_i + 1
    end
  end
end
