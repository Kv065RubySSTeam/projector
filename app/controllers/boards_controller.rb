# frozen_string_literal: true

# Boards controller
class BoardsController < ApplicationController
  # @!group Callbacks
  load_and_authorize_resource :board, except: %i[create export members]
  before_action :find_board!, except: %i[index new create]
  before_action :flash_clear, except: %i[index show]
  # @!endgroup

  # Returns set of boards
  # @url /boards/
  # @action GET
  # @required [User] current_user the logged in current user
  # @optional [String] filter the word indicates which filter to use
  # @optional [String] search the word or phrase from search form input
  # @optional [String] sort indicates in which order to sort boards
  # @optional [Integer] page indicates which page to show
  # @response [Set<Board>] @boards the set of boards
  def index
    @boards = Board.includes(:user)
                   .filter(params[:filter], current_user)
                   .search(params[:search])
                   .sorting(params[:sort])
                   .paginate(page: params[:page])
  end

  # Returns the board
  # @url /boards/:id
  # @action GET
  # @required [Integer] id the identifier of the board
  # @response [Board] @board the requested [board]
  # @response [Set<Column>] @columns the columns of this board
  # @response [Column] @column empty column that needs to set permissions
  def show
    @columns = @board.columns.order(position: :asc)
    @column = @board.columns.new
  end

  # Returns a form to create a new board
  # @url /boards/new
  # @action GET
  # @response [Board] @board empty board object to create form
  def new
    @board = Board.new
  end

  # Returns new form to create board
  # @url /boards/:id/edit
  # @action GET
  # @required [Integer] id Identifier the board
  def edit; end

  # Returns new board or renders new form with error
  # @url /boards/
  # @action POST
  # @required [User] current_user the logged in current user
  # @required [String] title the title for a board
  # @required [String] description the description for a board
  # @optional [Boolean] public the indicator public board or not
  # @response [Board] @board new board
  def create
    @board = Boards::CreateService.call(current_user, board_params)
    if @board.errors.empty?
      redirect_to @board
      flash[:success] = 'Board successfully created!'
    else
      render 'new', status: 422
    end
  end

  # Updates a board with new params or renders edit form with error
  # @url /boards/:id
  # @action PUT
  # @required [String] title the title for the board
  # @required [String] description the description for the board
  # @response [Board] @board updated board
  def update
    if @board.update(board_params)
      redirect_to @board
      flash[:success] = 'Board successfully updated!'
    else
      render 'edit', status: 422
    end
  end

  # Destroys board in DB with success flash or returns error with error flash
  # @url /boards/:id
  # @action DELETE
  # @required [Integer] id the identifier of the board
  def destroy
    if @board.destroy
      redirect_to root_path
      flash[:success] = 'Board successfully deleted!'
    else
      respond_to :js
      flash[:error] = 'Board has not been deleted! Something went wrong'
      render status: 422
    end
  end

  # Generates csv file with all information about the board
  # and sends it directly to the user or by email
  # @url /boards/:id/export
  # @action GET
  # @required [Integer] id the identifier of the board
  # @optional [Integer] export_id generated digest that needs to download file
  # @response [CSV] file file with all data about the board
  def export
    if !params[:export_id].nil?
      BoardJobs::ExportJob.perform_later(params[:export_id], @board)
    else
      BoardJobs::ExportMailJob.perform_later(current_user.email, @board)
    end
  end

  # Returns JSON with board members
  # @url /boards/:id/members
  # @action GET
  # @required [Integer] id the identifier of the board
  # @response [JSON] members with board members
  def members
    respond_to do |f|
      f.json { render json: @board.users }
    end
  end

  private

  def find_board!
    @board = Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:title, :description, :public)
  end

  def flash_clear
    flash.clear
  end
end
