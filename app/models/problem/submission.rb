require 'json'
require 'httparty'

module Problem
  class Submission
    include Mongoid::Document
    include Mongoid::Timestamps

    field :title, type: String

    belongs_to :user
    embeds_many :revisions, class_name: 'Problem::Revision', inverse_of: :problem
    has_many :solutions, class_name: 'Solution::Submission'

    validates_presence_of :title
  end
end
