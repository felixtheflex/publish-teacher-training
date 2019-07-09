source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'

# Use Puma as the app server
gem 'puma', '~> 4.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Manage multiple processes i.e. web server and webpack
gem 'foreman'

# Canonical meta tag
gem 'canonical-rails'

# DfE Sign-In
gem 'omniauth', '~> 1.8'
gem 'omniauth_openid_connect', '~> 0.3'

# App Insights for Azure
gem 'application_insights'
gem 'pkg-config', '~> 1.3.7'

# Parsing JSON from an API
gem 'json_api_client'

# For encoding/decoding web token used for authentication
gem 'jwt'

# Settings for the app
gem 'config'

# Sentry
gem 'sentry-raven'

# Decorate logic to keep it of the views and helper methods
gem 'draper'

# Render nice markdown
gem 'redcarpet'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # Factories to build models
  gem 'factory_bot_rails'

  # Get us some fake!
  gem 'faker'

  # GOV.UK interpretation of rubocop for linting Ruby
  gem 'govuk-lint'

  # Ability to render JSONAPI
  gem 'jsonapi-renderer'
  gem 'jsonapi-serializable'

  # Debugging
  gem 'pry-byebug'
  gem 'pry-rails'

  # Testing framework
  gem 'rspec-rails', '~> 3.8'

  # A Ruby static code analyzer and formatter
  gem 'rubocop', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # For better errors
  gem 'better_errors'
  gem 'binding_of_caller'

  # Run tests automatically
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'

  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'

  # Add Junit formatter for rspec
  gem 'rspec_junit_formatter'

  gem 'webmock'

  # Show test coverage %
  gem 'simplecov', require: false

  # Make diffs of Ruby objects much more readable
  gem 'super_diff'

  # Page object for Capybara
  gem 'site_prism'

  # Allows assert_template in request specs
  gem 'rails-controller-testing'

  gem 'knapsack'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
