module ProblemsHelper

  def link_to_source(problem, options = {})
    return '' if problem.source.blank?

    options = { icon: false }.merge(options)

    case problem.source
    when :stack_overflow
      link_to(options[:icon] ? image_tag('so-icon.png', width: '16px', style: 'vertical-align:baseline;') : 'Stack Overflow', "http://stackoverflow.com/q/#{problem.source_id}")
    else
      nil
    end
  end

end
