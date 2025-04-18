class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:query].to_s.strip
    @filter = params[:filter] || 'title'
    
    if @query.present?
      @jobs = perform_search(@query, @filter)
    else
      @jobs = Job.all.order(created_at: :desc)
    end
  end

  private

  def perform_search(query, filter)
    case filter
    when 'title'
      Job.where('LOWER(title) LIKE ?', "%#{query.downcase}%")
         .order(created_at: :desc)
    
    when 'budget'
      handle_budget_search(query)
    
    when 'category'
      handle_category_search(query)
    
    when 'skills'
      handle_skills_search(query)
    
    else
      Job.none
    end.limit(50)
  end
  
  def handle_budget_search(query)
    # Extract numeric value from query
    numeric_value = query.gsub(/[^\d.]/, '').to_f
    
    # Check for comparison operators
    if query.start_with?('>=')
      Job.where('budget >= ?', numeric_value)
    elsif query.start_with?('<=')
      Job.where('budget <= ?', numeric_value)
    elsif query.start_with?('>')
      Job.where('budget > ?', numeric_value)
    elsif query.start_with?('<')
      Job.where('budget < ?', numeric_value)
    elsif query.include?('..') # Range search (e.g., "100..500")
      min, max = query.split('..').map { |n| n.gsub(/[^\d.]/, '').to_f }
      Job.where(budget: min..max)
    else
      # Default to exact match or greater than if no operator specified
      Job.where('budget >= ?', numeric_value)
    end.order(budget: :asc)
  end

  def handle_category_search(query)
    # Search by category name through the association
    Job.joins(:category)
       .where('LOWER(categories.name) LIKE ?', "%#{query.downcase}%")
       .order(created_at: :desc)
  end

  def handle_skills_search(query)
    return Job.none if query.blank?
  
    skills = query.downcase.split(',').map(&:strip).reject(&:blank?)
  
    # Build a WHERE clause that checks if any skill is included as a substring
    conditions = skills.map { |skill| "LOWER(jobs.skills) LIKE ?" }.join(" OR ")
    values = skills.map { |skill| "%\"#{skill}\"%" }  # Assuming skills are stored like ["ruby", "react"]
  
    Job.where(conditions, *values).order(created_at: :desc)
  end
  
  
end