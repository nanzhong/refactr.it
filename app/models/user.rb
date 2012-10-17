class User
  include Mongoid::Document

  field :uid, type: String
  field :email, type: String
  field :nickname, type: String
  field :name, type: String
  field :image, type: String
  field :score, type: Integer, default: 0

  validates_presence_of :uid, :email, :nickname, :name, :score
  validates_uniqueness_of :uid

  def self.create_from_github(auth)
    user = User.new
    user.uid = auth['uid']
    user.email = auth['info']['email']
    user.nickname = auth['info']['nickname']
    user.name = auth['info']['name']
    user.image = auth['info']['image']
    user.create
  end
end
