Rails.application.routes.draw do
  resources :role_cutoffs
  resources :review_statuses
  resources :roles
  resources :role_types
  root 'static_pages#index'

  resources :contractor_requests
  resources :labor_requests
  resources :staff_requests
  resources :request_types
  resources :review_statuses
  resources :employee_types
  resources :employee_categories
  resources :units
  resources :departments
  resources :divisions
  resources :users

  resources :reports
  get '/reports/:id/download' => 'reports#download', as: :report_download

  get 'impersonate' => 'impersonate#index', as: :impersonate
  get 'impersonate/user/:user_id' => 'impersonate#create', as: :impersonate_user
  delete 'impersonate/revert' => 'impersonate#destroy', as: :revert_impersonate_user

  get '/logout' => 'users#logout'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
