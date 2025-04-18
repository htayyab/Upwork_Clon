module ProposalsHelper
    def file_icon_class(file)
      case file.content_type
      when 'application/pdf'
        'far fa-file-pdf text-danger'
      when 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        'far fa-file-word text-primary'
      when 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        'far fa-file-excel text-success'
      when 'image/jpeg', 'image/png', 'image/gif'
        'far fa-file-image text-info'
      else
        'far fa-file-alt'
      end
    end

    def status_badge_class(status)
      case status&.downcase
      when 'accepted' then 'bg-success'
      when 'rejected' then 'bg-danger'
      else 'bg-secondary'
      end
    end


    def status_row_class(status)
      case status.downcase
      when 'accepted' then 'table-success'
      when 'rejected' then 'table-danger'
      else ''
      end
    end
    
  end
  