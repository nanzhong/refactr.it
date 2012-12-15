class UsersController < ApplicationController

  before_filter :user_from_id, :only => [ :show, :authenticate ]

  def index
    @users_by_score = User.desc(:score).limit(10)
    @users_by_problems = User.desc(:problems_count).limit(10)
    @users_by_solutions = User.desc(:solutions_count).limit(10)
  end

  def show
    @activities = []

    @activities += @user.problems
    @activities += @user.solutions

    @activities += Problem.where(:'comments.user_id' => @user.id).map {|p| p.comments.where(:user_id => @user.id)}.flatten
    @activities += Solution.where(:'comments.user_id' => @user.id).map {|s| s.comments.where(:user_id => @user.id)}.flatten

    @activities.sort! {|a, b| a.created_at <=> b.created_at}
  end

  private
  def user_from_id
    @user = User.find(params[:id])
  end

end
