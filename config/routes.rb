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

    resources :recipients, only: [:index, :create, :update, :destroy]

    resources :videos do
      member do
        patch :end_voting
        patch :reopen_voting
        patch :update_ab_results
        get :preview_voting
        get :compose
        post :create_pair
        post :create_variant_inline
      end
      resources :video_shares, only: [:create, :destroy], path: "shares"
      resources :variants do
        resources :pairs, controller: "pairs" do
          member do
            patch :move
          end
        end
      end
    end
  end

  # Public preview & voting (recipient token required)
  get "p/:share_token/r/:recipient_token", to: "previews#show", as: :preview
  post "p/:share_token/r/:recipient_token/vote_variant", to: "votes#vote_variant", as: :vote_variant
  post "p/:share_token/r/:recipient_token/vote_pair", to: "votes#vote_pair", as: :vote_pair
  post "p/:share_token/r/:recipient_token/top_picks", to: "votes#vote_top_picks", as: :vote_top_picks
  post "p/:share_token/r/:recipient_token/feedback", to: "votes#submit_feedback", as: :submit_feedback

  # Voter profile
  get "profile", to: "profiles#show", as: :profile

  # Catch requests without recipient token
  get "p/:share_token", to: "previews#unauthorized", as: :preview_unauthorized
end
