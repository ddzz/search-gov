class SearchesController < ApplicationController

  before_filter :set_search_options

  def index
    @search = Search.new(@search_options)
    @search.run
  end

  private

  def set_search_options
    @search_options = {
      :page => (params[:page].to_i - 1),
      :query => params["query"]
    }
  end
end
