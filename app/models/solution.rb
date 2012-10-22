class Solution
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String

  belongs_to :user, index: true
  belongs_to :problem, index: true

  validates_presence_of :body
end
