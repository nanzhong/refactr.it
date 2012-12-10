class Solution
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body,       type: String
  field :up_votes,   type: Integer, default: 0
  field :down_votes, type: Integer, default: 0
  field :rating,     type: Integer, default: 0

  belongs_to :user, index: true
  belongs_to :problem, index: true
  embeds_many :comments

  validates_presence_of :body, :problem

  after_save :save_user
  after_destroy :save_user

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
  def save_user
    self.user.save unless self.user.nil?
  end
end
