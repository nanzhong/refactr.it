require 'redcarpet'
require 'tire'
require 'json'

class Problem
  include Mongoid::Document
  include Mongoid::Timestamps

  TAGS = ['ruby', 'python', 'c', 'c++', 'obj-c', 'java', 'javascript']

  field :title,           type: String
  field :body,            type: String,  default: ""
  field :tags,            type: Array,   default: []
  field :solutions_count, type: Integer, default: 0
  field :up_votes,        type: Integer, default: 0
  field :down_votes,      type: Integer, default: 0
  field :rating,          type: Integer, default: 0
  field :views,           type: Integer, default: 0

  belongs_to :user, index: true
  has_many :solutions, dependent: :destroy
  embeds_many :comments

  index({ tags: 1 })
  index({ created_at: 1})

  validates_presence_of :title, :body, :tags

  before_save :cache_solutions_count

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id,              index: :not_analyzed
    indexes :title
    indexes :body
    indexes :tags
    indexes :rating,          index: :not_analyzed
    indexes :solutions_count, index: :not_analyzed
    indexes :comments,        index: :not_analyzed
    indexes :created_at,      type: 'date'
  end

  def tags_str=(tags_str)
    self.tags = tags_str.split(',')
  end

  def tags_str
    return self.tags.join(',')
  end

  def tags_prepopulate
    return "[#{self.tags.map {|t| "{id:\"#{t}\", \"name\":\"#{t}\"}" }.join(',')}]".html_safe
  end

  def to_indexed_json
    self.to_json
  end

  def body_html
    @markdown = Redcarpet::Markdown.new(PrettyCode, autolink: true, space_after_headers: true)
    @markdown.render(self.body).html_safe
  end

  class PrettyCode < Redcarpet::Render::HTML
    def block_code(code, language)
      "<pre class=\"prettyprint linenums\"><code>" + code.gsub('<', '&lt;').gsub('>', '&gt;') + "</code></pre>"
    end
  end

  private
  def cache_solutions_count
    self.solutions_count = self.solutions.count
  end
end
