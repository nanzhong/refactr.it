require 'redcarpet'

class Problem
  include Mongoid::Document
  include Mongoid::Timestamps

  TAGS = ['ruby', 'python', 'c', 'c++', 'obj-c', 'java', 'javascript']

  field :title, type: String
  field :body, type: String, default: ""
  field :tags, type: Array, default: []
  field :up_votes, type: Integer, default: 0
  field :down_votes, type: Integer, default: 0
  field :rating, type: Integer, default: 0
  field :views, type: Integer, default: 0

  belongs_to :user
  has_many :solutions

  validates_presence_of :title, :body, :tags

  def tags_str=(tags_str)
    self.tags = tags_str.split(',')
  end

  def tags_str
    return self.tags.join(',')
  end

  def tags_prepopulate
    return "[#{self.tags.map {|t| "{id:\"#{t}\", \"name\":\"#{t}\"}" }.join(',')}]".html_safe
  end

  def body_html
    @markdown = Redcarpet::Markdown.new(PrettyCode, autolink: true, space_after_headers: true)
    @markdown.render(self.body).html_safe
  end

  class PrettyCode < Redcarpet::Render::HTML
    def block_code(code, language)
      "<pre class=\"prettyprint linenums\"><code>" + code + "</code></pre>"
    end
  end
end
