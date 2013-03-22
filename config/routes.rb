SavedList::Application.routes.draw do

  resources :places, except: :edit
  resources :saved_places, except: :edit
  resources :users, except: :edit
  
  # For catching OPTIONS and sending 200 status so that request will be resent (CORS)
  match '*all' => 'application#cors_preflight_check', :constraints => { :method => 'OPTIONS' }
  
  # For geo Google Places WS
  # match '/geo' => 'saved_places#geo'
  match '/places/get' => 'places#get', :constraints => { :method => 'POST' }
  
  # For Yelp
  match '/places/yelp' => 'places#yelp', :constraints => { :method => 'POST' }
  
  # For Open Table HTML parser
  match '/otp' => 'places#ot_parser' #, :constraints => { :method => 'POST' }
  
  # For creating a new unique user (if doesn't already exist)
  match '/users/new_unique_user' => 'users#new_unique_user', :constraints => { :method => 'POST' }
  
  # For user login
  match '/login' => 'users#login', :constraints => { :method => 'POST' }
  
  # For user setting if using password or not
  match '/users/setusepassword' => 'users#setusepassword', :constraints => { :method => 'POST' }
  
  # For getting user by email
  match '/users/userbyemail' => 'users#userbyemail', :constraints => { :method => 'POST' }

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
