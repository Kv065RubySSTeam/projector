module Api
  module V1
    class CommentsController < Api::V1::BaseController
      load_and_authorize_resource :comment, except: :create
      before_action :find_column!
      before_action :find_comment!, only: [:show, :update, :destroy]
      before_action :find_card!

      def index
        @comments = @card.comments.order(created_at: :desc).paginate(page: params[:page])
        render :index, status: 200
      end

      def show
        render :show, status: 200
      end

      def create
        @comment = @card.comments.build(comment_params)
        if @comment.save
          render :show, status: 201
        else
          render json: { errors: @comment.errors.full_messages }, status: 422
        end
      end

      def update
        if @comment.update(comment_params)
          render :show, status: 200
        else
          render json: { errors: @comment.errors.full_messages }, status: 422
        end
      end

      def destroy
        if @comment.destroy
          render json: { message: 'Comment successfully deleted.' }, status: 200
        else
          render json: { error: 'Unable to delete comment' }, status: 422
        end
      end

      private

      def find_comment!
        @comment = Comment.find(params[:id])
      end

      def find_column!
        @column = Column.find(params[:column_id])
      end

      def find_card!
        @card = Card.find(params[:card_id])
      end

      def comment_params
        params.require(:comment).permit(:body, :user_id)
      end

    end
  end
end
