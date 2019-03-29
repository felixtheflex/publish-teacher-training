Rails.application.routes.draw do
  # DfE Sign In
  get "/signin", to: "sessions#new", as: "signin"
  get "/signout", to: "sessions#signout", as: "signout"
  get "/auth/dfe/callback", to: "sessions#create"
  get "/auth/dfe/signout", to: "sessions#destroy"
  get "/auth/failure", to: "sessions#failure"

  root to: "providers#index"

  resources :providers, path: 'organisations', param: :code do
    get '/courses/:code',
      to: redirect { |path_params, req| helpers.manage_ui_course_page_url(provider_code: path_params[:provider_code], course_code: path_params[:code]) },
      as: :course

    resources :courses, param: :code, except: [:show] do
      get '/vacancies', on: :member, to: 'courses/vacancies#edit'
      put '/vacancies', on: :member, to: 'courses/vacancies#update'
    end
  end

  get "/cookies", to: "pages#cookies", as: :cookies
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/privacy-policy", to: "pages#privacy", as: :privacy

  match '/404', to: 'errors#not_found', via: :all
  match '/403', to: 'errors#forbidden', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
