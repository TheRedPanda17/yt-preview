Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root
  root "pages#home"

  # Admin authentication
  namespace :admin do
    get "signup", to: "registrations#new"
    post "signup", to: "registrations#create"
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    get "account", to: "account#edit"
    patch "account", to: "account#update"

    resources :videos do
      resources :variants do
        resources :pairs, controller: "pairs" do
          member do
            patch :move
          end
        end
      end
    end
  end

  # Public preview & voting
  get "p/:share_token", to: "previews#show", as: :preview
  post "p/:share_token/identify", to: "previews#identify", as: :preview_identify
  post "p/:share_token/vote_variant", to: "votes#vote_variant", as: :vote_variant
  post "p/:share_token/vote_pair", to: "votes#vote_pair", as: :vote_pair
end
