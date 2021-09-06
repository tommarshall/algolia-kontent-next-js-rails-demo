Rails.application.routes.draw do
  namespace :webhooks, defaults: { format: :json } do
    post :kentico
  end
end
