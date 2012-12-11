class RootController < ApplicationController

  def index
    @problems = Problem.desc(:created_at).limit(5)
    @users = User.desc(:score).limit(5)
  end

end
