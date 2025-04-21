class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:query].to_s.strip
    @filter = params[:filter] || 'title'

    @jobs = if @query.present?
               Job.search_by(@query, @filter)
             else
               Job.all.order(created_at: :desc)
             end
  end
end
