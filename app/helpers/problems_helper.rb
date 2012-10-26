module ProblemsHelper

  def link_to_source(problem)
    return '' if problem.source.blank?

    case problem.source
      when :stack_overflow
        link_to(image_tag('http://cdn.sstatic.net/stackoverflow/img/icon-48.png', width: '24px') + 'Stack Overflow', "http://stackoverflow.com/q/#{problem.source_id}")
      else
        nil
    end
  end

end
