class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:uid => auth['uid']).first
    if user.nil?
      user = User.create_from_github(auth)
    else
      user.update_from_github(auth)
    end

    session[:user_id] = user.id
    redirect_to session['return_to'] || root_url, :notice => 'Signed in!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

  def new
    session['return_to'] = request.referer
    redirect_to '/auth/github'
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

end
