module Solution
  class Revision
    include Mongoid::Document
    include Mongoid::Timestamps

    field :body, type: String

    embedded_in :solution, class_name: 'Solution::Submission', inverse_of: :revisions

    validates_presence_of :body
  end
end
