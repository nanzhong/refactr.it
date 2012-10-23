class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String
  field :user_id, type: Moped::BSON::ObjectId
  field :user_display_name, type: String

  embedded_in :problem
  embedded_in :solution

  validates_presence_of :body, :user_id, :user_display_name
end
