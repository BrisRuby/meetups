Chat::Application.routes.draw do
  resources :chat, :only => [:index]

  resources :login

  root :to => "login#index"
end
