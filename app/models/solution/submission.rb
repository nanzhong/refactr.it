module Solution
  class Submission
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :user
    belongs_to :problem, class_name: 'Problem::Submission', inverse_of: :solutions
    embeds_many :revisions, class_name: 'Solution::Revision', inverse_of: :solution

    validates_presence_of :body
  end
end
