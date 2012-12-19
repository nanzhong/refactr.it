class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uid, type: String
  field :email, type: String
  field :nickname, type: String
  field :name, type: String
  field :image, type: String
  field :score, type: Integer, default: 0
  field :problems_count, type: Integer, default: 0
  field :solutions_count, type: Integer, default: 0

  has_many :problems
  has_many :solutions

  index({ uid: 1 }, { unique: true })
  index({ email: 1 })
  index({ score: 1 })
  index({ problems_count: 1 })
  index({ solutions_count: 1 })

  validates_presence_of :uid, :score
  validates_uniqueness_of :uid

  before_save :calculate_score
  before_save :cache_counts

  def self.create_from_github(auth)
    User.create!({
      uid: auth['uid'],
      email: auth['info']['email'],
      nickname: auth['info']['nickname'],
      name: auth['info']['name'],
      image: auth['info']['image'] })
  end

  def update_from_github(auth)
    self.email = auth['info']['email']
    self.nickname = auth['info']['nickname']
    self.name = auth['info']['name']
    self.image = auth['info']['image']
    self.save
  end

  def display_name
    self.name || self.nickname || self.email
  end

  private
  def calculate_score
    self.score = self.problems.map { |p| p.rating + 1 }.inject(:+) || 0
    self.score += self.solutions.map { |s| s.rating + 1 }.inject(:+) || 0
  end

  def cache_counts
    self.problems_count = self.problems.count
    self.solutions_count = self.solutions.count
  end

end
