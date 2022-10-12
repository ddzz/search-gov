require 'simplecov'
SimpleCov.command_name 'Cucumber'

# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'
require 'capybara/rails'
require 'email_spec/cucumber'
require 'capybara-screenshot/cucumber'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_max_wait_time = 10
Capybara::Screenshot.autosave_on_failure = true

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--window-size=1200,768')

  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 options: options)
end

Capybara.javascript_driver = :selenium_chrome_headless

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :truncation,
                             { except: %w[email_templates
                                          languages
                                          templates] }

  Cucumber::Rails::Database.javascript_strategy = :truncation,
                                                  { except: %w[email_templates
                                                               languages
                                                               templates] }
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end

module ScenarioStatusTracker
  class << self
    attr_accessor :success
  end

  self.success = true
end

require_relative '../../spec/test_services.rb'
require_relative '../../spec/support/omniauth_helpers.rb'

World OmniauthHelpers

After { OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({}) }

EmailTemplate.load_default_templates
OutboundRateLimit.load_defaults

TestServices::create_es_indexes

at_exit do
  TestServices::delete_es_indexes
  exit ScenarioStatusTracker.success
end
Capybara.asset_host = "http://localhost:3000"
