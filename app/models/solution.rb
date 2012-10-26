require 'redcarpet'

class Solution
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body,       type: String
  field :up_votes,   type: Integer, default: 0
  field :down_votes, type: Integer, default: 0
  field :rating,     type: Integer, default: 0
  field :parsed,     type: Boolean, default: false
  field :source,     type: Symbol
  field :source_id,  type: String

  belongs_to :user, index: true
  belongs_to :problem, index: true
  embeds_many :comments

  validates_presence_of :body, :problem

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
