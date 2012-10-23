class User
  include Mongoid::Document

  field :uid, type: String
  field :email, type: String
  field :nickname, type: String
  field :name, type: String
  field :image, type: String
  field :score, type: Integer, default: 0

  has_many :problems
  has_many :solutions

  index({ uid: 1 }, { unique: true })
  index({ email: 1 }, { unique: true })
  index({ score: 1 })

  validates_presence_of :uid, :email, :score
  validates_uniqueness_of :uid

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
    self.nickname || self.email
  end

end
