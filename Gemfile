source 'https://rubygems.org'

gem 'rails', '3.2.16'

gem "mongoid", "~> 3.1.6"
gem "origin"
gem "aasm", "~> 3.0.25"
gem "nokogiri", "~> 1.6.1"
gem "bunny"
gem 'jquery-rails'
gem 'jquery-ui-rails'

group :development do
  gem 'capistrano', '2.15.4'
  gem 'ruby-progressbar'
#  gem 'jazz_hands'
end

group :development, :assets do
  gem 'sass-rails',   '~> 3.2.3', :group => :test
  gem 'coffee-rails', '~> 3.2.1', :group => :test
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer', :platforms => :ruby
  gem 'less-rails-bootstrap', :group => :test
  gem 'designmodo-flatuipro-rails', '~> 1.3.0.0.branch', :group => :test
  gem 'font-awesome-rails'
end

group :test do
	gem 'mongoid-rspec'
  gem 'rspec-rails' #, '~> 3.0.0.beta'
  gem 'capybara'
  gem "capybara-webkit"
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'ci_reporter'
end

group :production do
  gem 'unicorn'
end

gem "haml"
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem "pd_x12"
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'devise'
gem "rsec"
gem "mongoid_auto_increment"
gem 'american_date'
gem 'cancancan', '~> 1.9'
gem 'oj'
gem 'roo'
gem 'bh'
