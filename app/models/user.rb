class User
  include Mongoid::Document

  field :uid, type: String
  field :email, type: String
  field :nickname, type: String
  field :name, type: String
  field :image, type: String
  field :score, type: Integer, default: 0

  has_many :problems, class_name: 'Problem::Submission', inverse_of: :user
  has_many :solutions, class_name: 'Solution::Submission', inverse_of: :user

  validates_presence_of :uid, :email, :nickname, :name, :score
  validates_uniqueness_of :uid

  def self.create_from_github(auth)
    User.create!({
      uid: auth['uid'],
      email: auth['info']['email'],
      nickname: auth['info']['nickname'],
      name: auth['info']['name'],
      image: auth['info']['image'] })
  end
end
