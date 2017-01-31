class LoginController < ApplicationController
  def index
  end

  def create
    login = params[:login]
    user = User.where(name: login).first
    user = User.create_new(login) if user.nil?
    user.update_token
    user.welcome
    session[:name] = user.name
    redirect_to chat_index_path
  end
end