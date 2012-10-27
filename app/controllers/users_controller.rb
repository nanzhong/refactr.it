class UsersController < ApplicationController

  before_filter :user_from_id, :only => [ :show, :authenticate ]

  def index
    @users_by_score = User.desc(:score).limit(10)
    @users_by_problems = User.desc(:problems_count).limit(10)
    @users_by_solutions = User.desc(:solutions_count).limit(10)
  end

  def show

  end

  private
  def user_from_id
    @user = User.find(params[:id])
  end

end
