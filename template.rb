# frozen_string_literal: true

say 'Updating rails to run minitests/spec'

gem_group :test do
  gem 'minitest-spec-rails', require: false
  gem 'rspec-expectations', require: false
end

say <<~MSG
  **************************
  DO NOT FORGET TO INSTALL CODE QUALITY TOOLS:
    `rails app:template LOCATION=https://raw.githubusercontent.com/jetthoughts/jt_tools/master/template.rb`
  **************************
MSG
