# frozen_string_literal: true

class TagsController < ApplicationController
  load_and_authorize_resource :card
  before_action :find_card!, only: %i[create destroy]
  respond_to :js

  def create
    @card.tag_list.add(tag_params[:name])
    if @card.save
      @tag = @card.tags.find_by(name: tag_params[:name])
      flash[:success] = 'Tag was successfully added!'
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  def destroy
    @tag = @card.tags.find(params[:id])
    @card.save if @card.tag_list.remove(@tag.name)
    if @card.errors.empty?
      flash[:success] = "Tag: #{@tag.name} was successfully deleted."
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  private

  def find_card!
    @card = Card.find(params[:card_id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
