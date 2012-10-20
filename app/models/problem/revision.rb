require 'json'
require 'httparty'

module Problem
  class Revision
    include Mongoid::Document
    include Mongoid::Timestamps

    field :body, type: String

    embedded_in :problem, class_name: 'Problem::Submission', inverse_of: :revisions

    validates_presence_of :body
  end
end
