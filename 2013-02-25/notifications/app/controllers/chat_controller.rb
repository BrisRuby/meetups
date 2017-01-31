class ChatController < ApplicationController
  def index
    @user = User.where(name: session[:name]).first
  end
end