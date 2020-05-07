# frozen_string_literal: true

say 'Updating rails to run minitests/spec'

source_paths.unshift(__dir__)

gem 'minitest-spec-rails', require: false, group: :test
gem 'rspec-expectations', require: false, group: :test
gem 'capybara', require: false, group: :test

`bundle install`

directory 'lib/install/test', 'test'

insert_into_file('test/test_helper.rb', <<~TEST_HELPER_SNIPPET, before: 'class ActiveSupport::TestCase')

  require 'minitest-spec-rails'
  require 'rspec/expectations/minitest_integration'

  require_relative 'support/shared_examples'

TEST_HELPER_SNIPPET


say <<~MSG
  **************************
  DO NOT FORGET TO INSTALL CODE QUALITY TOOLS:
    `rails app:template LOCATION=https://raw.githubusercontent.com/jetthoughts/jt_tools/master/template.rb`
  **************************
MSG
