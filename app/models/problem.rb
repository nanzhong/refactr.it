require 'json'
require 'httparty'

class Problem
  include Mongoid::Document

  field :title, type: String
  field :description, type: String
  field :gist, type: Integer

  validates_presence_of :title, :description, :gist

  def self.create_on_github(data)
    response = HTTParty.post('https://api.github.com/gists', body: data)
    @problem = Problem.new

    response_hash = JSON.parse(response.body)

    case response.code
    when 201
      @problem.title = data['title']
      @problem.description = data['description']
      @problem.gist = response_hash['id']
      @problem.save
    when 422
      @problem.errors.add(:gist, response_hash['errors'].to_json)
    when 404
      @problem.errors.add(:gist, "Github api 404")
    else
      @problem.errors.add(:gist, "Unknown error: #{response}")
    end

    @problem
  end

  def api_url
    "https://api.github.com/gists/#{self.gist}"
  end

  def gist_url
    "https://gist.github.com/#{self.gist}"
  end

  def embed_url
    self.gist_url + ".js"
  end
end
