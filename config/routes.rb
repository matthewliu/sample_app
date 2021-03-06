SampleApp::Application.routes.draw do

  #Adding resources allow the app to use the standard RESTful actions. Then the actions can be mapped to pages below.
  resources :users do
    member do
      #Creates users/id/following and users/id/followers
      get :following, :followers
    end
  end

  get "sessions/new"
  
  resources :sessions, :only => [:new, :create, :destroy]
  #Can limit RESTful routes since micropost actions are happening on the user and page controllers
  resources :microposts, :only => [:create, :destroy]
  resources :relationships, :only => [:create, :destroy]

  # Maps browser requests to Pages controller actions
  #get "pages/about"
  #get "pages/home"
  #get "pages/contact"
  #get "pages/help"

  # Matches URL and RESTful requests to 'controller#action'
  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'
  match '/signup',  :to => 'users#new'
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  
  # This is the default when generating scaffold and model (with database columns). 
  # The related ontrollers have HTTP requests as actions. In contrast, when just generating a controller, the actions are not HTTP requests.

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  root :to => "pages#home"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
