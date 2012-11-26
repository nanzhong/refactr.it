class RootController < ApplicationController

  def index
    @problems = Problem.desc(:date).limit(5)
    @users = User.desc(:score).limit(5)
  end

end
