# frozen_string_literal: true

require 'thor'

module R2M
  # Process input RSpec and convert it to minitest
  class SpecConvector # rubocop:todo Metrics/ClassLength
    def initialize(command)
      @command = command
    end

    def process(file)
      #   it 'converts it"s to test method with # support' do # => def test_converts_it_s_to_test_method_with_support
      convert_require_helpers(file)
      convert_declarations(file)
      convert_declarations(file)
      convert_context_to_describe(file)
      convert_it_to_methods(file)
      convert_helpers_suites(file)
      convert_mather_be_empty(file)
      convert_simple_matcher(file)
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
      @command.gsub_file(file, /require (['"]?)rspec\1/, "require 'minitest/autorun'")
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

    def convert_helpers_suites(file)
      @command.gsub_file(file, /\bhelper\./, '') if located_in_helpers?(file)
    end

    # rubocop:todo Metrics/MethodLength
    def convert_declarations(file) # rubocop:todo Metrics/AbcSize
      @command.gsub_file(file, /RSpec\.describe (['"])(.*?)\1 do\b/) do |match|
        title = match[/RSpec\.describe (['"])(.*?)\1 do/, 2]

        # rubocop:todo Naming/VariableName
        camelCasedTitle = title.split('::').map do |title_part|
          title_part
            .split
            .reject(&:empty?)
            .map { |part| part[0].upcase + part[1..-1] }.join
        end.join('::')
        # rubocop:enable Naming/VariableName

        # rubocop:todo Naming/VariableName
        "RSpec.describe '#{camelCasedTitle}' do"
        # rubocop:enable Naming/VariableName
      end

      @command.gsub_file(
        file,
        /RSpec\.describe ['"]?(.+?Controller)['"]? do\b/,
        'class \1Test < ActionController::TestCase'
      )
      @command.gsub_file(
        file,
        /RSpec\.describe ['"]?(.+?Mailer)['"]? do\b/,
        'class \1Test < ActionMailer::TestCase'
      )

      @command.gsub_file(
        file,
        /RSpec\.describe ['"]?(.+?Helper)['"]? do\b/,
        'class \1Test < ActionView::TestCase'
      )

      if located_in_requests?(file)
        @command.gsub_file(
          file,
          /RSpec\.describe ['"]?(.+?)['"]? do\b/,
          'class \1Test < ActionDispatch::IntegrationTest'
        )
      end

      if located_in?(file, :systems)
        @command.gsub_file(
          file,
          /RSpec\.describe ['"]?(.+?)['"]? do\b/,
          'class \1Test < ApplicationSystemTestCase'
        )
      end

      @command.gsub_file(
        file,
        /RSpec\.describe ['"]?(.+?)['"]? do\b/,
        'class \1Test < ActiveSupport::TestCase'
      )
    end
    # rubocop:enable Metrics/MethodLength

    MANUAL_AROUND_PROCESS = "skip 'TODO: Remove this skip when `around` will be migrated manually by replacing `run` with `call`'"
    def convert_around(file)
      @command.gsub_file(file, /^\s*?\baround\b.+?\bdo\b.*?$/) do |match|
        "#{MANUAL_AROUND_PROCESS}\n#{match}"
      end
    end

    private

    def located_in_helpers?(file)
      located_in?(file, :helpers)
    end

    def located_in_requests?(file)
      located_in?(file, :requests)
    end

    def located_in?(file, sub_folder)
      file =~ %r{(test|spec)/#{sub_folder}/}
    end
  end
end
