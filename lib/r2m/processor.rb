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

    # Finds +be_empty+ RSpec matchers and converts to minitest matchers
    #
    #   expect(target).to be_empty # => expect(target).must_be_empty
    #   expect(target).to_not be_empty # => expect(target).wont_be_empty
    #   expect(target).not_to be_empty # => expect(target).wont_be_empty
    def convert_mather_be_empty(file)
      @command.gsub_file(file, /\.to be_empty/, '.must_be_empty')
      @command.gsub_file(file, /\.(to_not|not_to) be_empty/, '.wont_be_empty')
    end
  end
end
