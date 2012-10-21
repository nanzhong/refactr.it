class Solution
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String

  belongs_to :user
  belongs_to :problem

  validates_presence_of :body
end
