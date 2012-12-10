module ApplicationHelper
  def title(page_title)
    content_for :title, "refactr.it - #{page_title.to_s}"
  end
end
