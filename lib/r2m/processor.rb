# frozen_string_literal: true

require 'thor'

module R2M
  # Process input RSpec and convert it to minitest
  class Processor
    def initialize(command)
      @command = command
    end

    def process(file)
      #   it 'converts it"s to test method with # support' do # => def test_converts_it_s_to_test_method_with_support
      convert_it_to_methods(file)
    end

    # Finds +it+ cases and converts to test methods declarations
    #
    #   it 'converts it"s to test method with # support' do
    #   # => def test_converts_it_s_to_test_method_with_support
    def convert_it_to_methods(file)
      @command.gsub_file(file, /(?<=\bit ').*?(?=' do\b)/) do |match|
        match.gsub(/\W+/, '_').downcase
      end

      @command.gsub_file(file, /it '_?(.*)' do/, 'def test_\1')
    end

    # Finds +it+ cases and converts to test methods declarations
    #
    #   context 'with context' do # => describe 'with context' do
    def convert_context_to_describe(file)
      @command.gsub_file(file, /\bcontext( '.*?' do\b)/, 'describe\1')
    end

    # Finds +it+ cases and converts to test methods declarations
    #
    #   context 'with context' do # => describe 'with context' do
    def convert_require_helpers(file)
      @command.gsub_file(file, /\bsystem_helper\b/, 'application_system_test_case')
      @command.gsub_file(file, /\b(rails_helper|spec_helper)\b/, 'test_helper')
    end

    # Finds +be_empty+ RSpec matchers and converts to minitest matchers
    #
    #   expect(target).to be_empty # => expect(target).must_be_empty
    #   expect(target).to_not be_empty # => expect(target).wont_be_empty
    #   expect(target).not_to be_empty # => expect(target).wont_be_empty
    def convert_mather_be_empty(file)
      @command.gsub_file(file, /\.to be_empty/, '.must_be_empty')
      @command.gsub_file(file, /\.(to_not|not_to) be_empty/, '.wont_be_empty')
    end

    # Finds +equal+ RSpec matchers and converts to minitest matchers
    #
    #   expect(target).to eq expect # => expect(target).must_equal expect
    #   expect(target).not_to eq expect # => expect(target).wont_equal expect
    def convert_simple_matcher(file)
      @command.gsub_file(file, /\.(to_not|not_to|to)\s+(eq|include|match|be_kind_of)\b/) do |match|
        match
          .gsub(/\s+/, ' ')
          .gsub(/\.\w+ /, '.to_not ' => '.wont_', '.not_to ' => '.wont_', '.to ' => '.must_')
          .gsub(/(?<=_)eq/, 'equal')
      end
    end
  end
end
