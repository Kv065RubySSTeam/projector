# frozen_string_literal: true

module Api
  module V1
    class TagsController < Api::V1::BaseController
      load_and_authorize_resource :card
      before_action :find_card!
      before_action :find_tag!, only: %i[destroy show]

      def index
        @tags = @card.tags
      end

      def show; end

      def create
        @card.save if @card.tag_list.add(tag_params[:name])
        @tag = @card.tags.find_by(name: tag_params[:name])
        if @tag
          render :show, status: 200
        else
          render json: { error: 'Name is to short' }, status: 422
        end
      end

      def destroy
        @card.save if @card.tag_list.remove(@tag.name)
        if @card.errors.empty?
          render json: { message: 'Tag successfully deleted.' }, status: 200
        else
          render json: { error: 'Unable to delete tag' }, status: 422
        end
      end

      private

      def find_card!
        @card = Card.find(params[:card_id])
      end

      def find_tag!
        @tag = @card.tags.find(params[:id])
      end

      def tag_params
        params.require(:tag).permit(:name)
      end
    end
  end
end
