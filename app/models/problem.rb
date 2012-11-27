require 'tire'
require 'json'

class Problem
  include Mongoid::Document
  include Mongoid::Timestamps

  LANGUAGES = [
    :c_cpp,      :clojure,    :coffee,     :csharp,     :dart,       :golang,
    :groovy,     :java,       :javascript, :jsp,        :list,       :lua,
    :objectivec, :ocaml,      :perl,       :php,        :python,     :ruby,
    :scala,      :sh,         :sql,        :tcl,        :text,       :typescript
  ]

  TAGS = ['ruby', 'python', 'c', 'c++', 'obj-c', 'java', 'javascript']

  field :title,           type: String
  field :body,            type: String,  default: ""
  field :language,        type: Symbol
  field :tags,            type: Array,   default: []
  field :solutions_count, type: Integer, default: 0
  field :up_votes,        type: Integer, default: 0
  field :down_votes,      type: Integer, default: 0
  field :rating,          type: Integer, default: 0
  field :views,           type: Integer, default: 0

  belongs_to :user, index: true
  has_many :solutions, dependent: :destroy
  embeds_many :comments

  index({ language: 1 })
  index({ tags: 1 })
  index({ created_at: 1 })

  validates_presence_of :title, :body, :language, :tags

  before_save :cache_solutions_count
  after_save :save_user

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id,              index: :not_analyzed
    indexes :title
    indexes :body
    indexes :tags
    indexes :rating,          index: :not_analyzed
    indexes :views,           index: :not_analyzed
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

  def up_vote
    self.inc(:up_votes, 1)
    self.inc(:rating, 1)
    self.user.save unless self.user.nil?
  end

  def down_vote
    self.inc(:down_votes, 1)
    self.inc(:rating, -1)
    self.user.save unless self.user.nil?
  end

  private
  def cache_solutions_count
    self.solutions_count = self.solutions.count
  end

  def save_user
    self.user.save
  end
end
