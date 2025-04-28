class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:query]
    @filter = params[:filter] || 'title'
    @jobs = Job.search_by(@query, @filter)
  end
end
