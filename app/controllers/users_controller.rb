class UsersController < ApplicationController

  before_filter :user_from_id, :only => [ :show, :authenticate ]

  def index
    @users = User.all
  end

  def show

  end

  private
  def user_from_id
    @user = User.find(params[:id])
  end

end
