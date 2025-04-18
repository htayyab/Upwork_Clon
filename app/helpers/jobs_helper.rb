module JobsHelper
    def status_badge_class(status)
      return 'bg-secondary' if status.blank?
  
      case status.to_s.downcase
      when 'open', 'active', 'pending'
        'bg-primary'
      when 'completed', 'closed', 'accepted'
        'bg-success'
      when 'cancelled', 'rejected'
        'bg-danger'
      when 'in_progress', 'processing'
        'bg-warning text-dark'
      else
        'bg-secondary'
      end
    end
  
    # Format budget with currency symbol and proper decimals
    def format_budget(budget)
      number_to_currency(budget, precision: 2)
    end
    
    def posted_time(created_at)
      "Posted #{time_ago_in_words(created_at)} ago"
    end
  
    def display_status(status)
      content_tag(:span, status.to_s.humanize, class: "badge #{status_badge_class(status)}")
    end
  end