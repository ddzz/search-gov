UsasearchRails3::Application.routes.draw do
  resource :account, :controller => "users"
  resources :users, :except => [:new]
  resource :user_session
  resources :password_resets
  resources :email_verification, :only => :show
  resources :complete_registration, :only => [:edit, :update]
  get '/affiliates', to: redirect('/sites')
  get '/affiliates/:id', to: redirect('/sites/%{id}')
  get '/affiliates/:id/:some_action', to: redirect('/sites/%{id}')

  scope module: 'sites' do
    resources :sites do
      member { put :pin }

      resource :advanced_display, only: [:edit]
      resource :api_instructions, only: [:show]
      resource :clicks, only: [:new, :create]
      resource :query_clicks, only: [:show]
      resource :click_queries, only: [:show]
      resource :queries, only: [:new, :create]

      resource :content, only: [:show]
      resource :display, only: [:edit, :update] do
        collection { get :new_connection }
      end
      resource :embed_code, only: [:show]
      resource :font_and_colors, only: [:edit, :update]
      resource :header_and_footer, only: [:edit, :update] do
        collection do
          get :new_footer_link
          get :new_header_link
        end
      end
      resource :image_assets, only: [:edit, :update]
      resource :monthly_reports, only: [:show]
      resource :best_bets_drill_down, only: [:show]
      resource :best_bet_queries, only: [:show]
      resource :preview, only: [:show]
      resource :raw_logs_access, only: [:new, :create]
      resource :setting, only: [:edit, :update]
      resource :supplemental_feed,
               controller: 'site_feed_urls',
               only: [:edit, :create, :update, :destroy]
      resource :third_party_tracking_request, only: [:new, :create]

      resources :best_bets_graphics, controller: 'featured_collections', except: [:show] do
        collection do
          get :new_keyword
          get :new_link
        end
      end

      resources :best_bets_texts, controller: 'boosted_contents', except: [:show] do
        collection do
          get :new_keyword
          get :new_bulk_upload
          post :bulk_upload
        end
      end

      resources :best_bets_texts_bulk_upload, controller: 'boosted_contents_bulk_uploads', only: [:new, :create]

      resources :collections, controller: 'document_collections' do
        collection { get :new_url_prefix }
      end
      resources :domains, except: [:show] do
        member { get :advanced }
      end
      resources :filter_urls,
                controller: 'excluded_urls',
                only: [:index, :new, :create, :destroy]
      resources :flickr_urls,
                controller: 'flickr_profiles',
                only: [:index, :new, :create, :destroy]
      resources :rss_feeds do
        collection { get :new_url }
      end
      resources :supplemental_urls,
                controller: 'indexed_documents',
                except: [:show, :edit, :update]
      resources :twitter_handles,
                controller: 'twitter_profiles',
                only: [:index, :new, :create, :destroy]
      resources :users, only: [:index, :new, :create, :destroy]
      resources :youtube_usernames,
                controller: 'youtube_profiles',
                only: [:index, :new, :create, :destroy]
      resources :memberships, only: [:update]
    end
  end

  get '/search' => 'searches#index', as: :search, defaults: { host: USASEARCH_HOST }
  get '/search/advanced' => 'searches#advanced', as: :advanced_search, defaults: { host: USASEARCH_HOST }
  get '/search/images' => 'image_searches#index', as: :image_search, defaults: { host: USASEARCH_HOST }
  get '/images' => 'images#index', as: :images, defaults: { host: USASEARCH_HOST }
  namespace :api do
    namespace :v1 do
      get '/agencies/search' => 'agencies#search', :defaults => { :format => 'json' }
    end
  end
  get '/search/docs' => 'searches#docs', as: :docs_search, defaults: { host: USASEARCH_HOST }
  get '/search/news' => 'searches#news', as: :news_search, defaults: { host: USASEARCH_HOST }
  get '/search/news/videos' => 'searches#video_news', as: :video_news_search, defaults: { host: USASEARCH_HOST }

  namespace :admin do
    resources :affiliates do as_routes end
    resources :affiliate_notes do as_routes end
    resources :affiliate_templates do as_routes end
    resources :users do as_routes end
    resources :sayt_filters do as_routes end
    resources :sayt_suggestions do as_routes end
    resources :misspellings do as_routes end
    resources :affiliate_boosted_contents do as_routes end
    resources :document_collections do as_routes end
    resources :url_prefixes do as_routes end
    resources :catalog_prefixes do as_routes end
    resources :site_feed_urls do as_routes end
    resources :superfresh_urls do as_routes end
    resources :superfresh_urls_bulk_upload, :only => :index do
      collection do
        post :upload
      end
    end
    resources :agencies do as_routes end
    resources :agency_urls do as_routes end
    resources :agency_queries do as_routes end
    resources :logfile_blocked_queries do as_routes end
    resources :logfile_blocked_ips do as_routes end
    resources :logfile_blocked_class_cs do as_routes end
    resources :logfile_whitelisted_class_cs do as_routes end
    resources :logfile_blocked_regexps do as_routes end
    resources :logfile_blocked_user_agents do as_routes end
    resources :search_modules do as_routes end
    resources :excluded_domains do as_routes end
    resources :affiliate_scopes do as_routes end
    resources :site_domains do as_routes end
    resources :features do as_routes end
    resources :affiliate_feature_additions do as_routes end
    resources :help_links do as_routes end
    resources :search_module_stats, :only => :index
    resources :synonyms do as_routes end
    resources :monthly_reports, :only => :index
    resources :affiliate_reports, :only => :index
    resources :email_templates do as_routes end
    resources :compare_search_results, :only => :index
    resources :bing_urls do as_routes end
    resources :statuses do as_routes end
    resources :system_alerts do as_routes end
    resources :tags do as_routes end
    resources :trending_urls, :only => :index
    resources :news_items do as_routes end
    resources :rss_feeds do as_routes end
    resources :rss_feed_urls do as_routes end
  end
  match '/admin/search_module_stats' => 'admin/search_module_stats#index', :as => :admin_search_module_stats
  match '/admin/affiliates/:id/analytics' => 'admin/affiliates#analytics', :as => :affiliate_analytics_redirect
  match '/admin/site_domains/:id/trigger_crawl' => 'admin/site_domains#trigger_crawl', :as => :site_domain_trigger_crawl
  match '/admin' => 'admin/home#index', :as => :admin_home_page

  get '/' => 'home#index', :as => :home_page
  get '/superfresh' => 'superfresh#index', :as => :main_superfresh_feed
  get '/superfresh/:feed_id' => 'superfresh#index', :as => :superfresh_feed
  get '/api/search' => 'api#search', as: :api_search, defaults: { host: USASEARCH_HOST }
  get '/user/developer_redirect' => 'users#developer_redirect', :as => :developer_redirect
  get '/login' => 'user_sessions#new', :as => :login
  get "/sayt" => "sayt#index"
  get "/clicked" => "clicked#index"
  get '/program' => redirect(BLOG_URL, :status => 302)
  get '/help_docs' => 'help_docs#show', defaults: { format: :json }
  get "/404/:name" => "errors#page_not_found", :constraints => { :name => /.+/ }, :as => 'affiliate_page_not_found'
  get "/404" => "errors#page_not_found", :as => 'page_not_found'
  get "*path" => "errors#page_not_found"
  root :to => "home#index"
end
