# frozen_string_literal: true

require 'test_helper'

require 'r2m/command'
require 'r2m/spec_convertor'

module R2M
  class SpecConvertorTest < Minitest::Test
    def test_convert_it_to_methods
      rspec_in = <<~IT_SPEC
        it '"converts" to test method with # support' do
          assert true
        end
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        def test_converts_to_test_method_with_support
          assert true
        end
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_it_to_methods(file)
      end
    end

    def test_convert_matcher_be_empty
      rspec_in = <<~IT_SPEC
        expect(target).to be_empty
        expect(target).to_not be_empty
        expect(target).not_to be_empty
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        expect(target).must_be_empty
        expect(target).wont_be_empty
        expect(target).wont_be_empty
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_mather_be_empty(file)
      end
    end

    def test_convert_simple_matcher
      rspec_in = <<~IT_SPEC
        expect(target).to eq expect
        expect(target).to include expect
        expect(target).to be_kind_of expect
        expect(target).to match /expect/
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        expect(target).must_equal expect
        expect(target).must_include expect
        expect(target).must_be_kind_of expect
        expect(target).must_match /expect/
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_simple_matcher(file)
      end
    end

    def test_convert_context_to_describe
      rspec_in = <<~IT_SPEC
        context 'test' do
          it { expect(target).to be_empty }
        end
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        describe 'test' do
          it { expect(target).to be_empty }
        end
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_context_to_describe(file)
      end
    end

    def test_convert_require_helpers
      rspec_in = <<~IT_SPEC
        require 'system_helper'
        require 'rails_helper'
        require 'spec_helper'
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        require 'application_system_test_case'
        require 'test_helper'
        require 'test_helper'
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_require_helpers(file)
      end
    end

    def test_convert_helpers_suites_when_in_helpers_folder
      rspec_in = <<~IT_SPEC
        helper.some_rails_helper_method
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        some_rails_helper_method
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in, dir: 'helpers') do |file|
        SpecConvertor.new(Command.new).convert_helpers_suites(file)
      end
    end

    def test_convert_helpers_suites_when_not_in_helpers_folder
      rspec_in = <<~IT_SPEC
        helper.some_rails_helper_method
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        helper.some_rails_helper_method
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_helpers_suites(file)
      end
    end

    def test_convert_declarations_when_controller_in_the_name
      rspec_in = <<~IT_SPEC
        RSpec.describe Admin::TestableController do
        RSpec.describe 'Admin::QuotedTestableController' do
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        class Admin::TestableControllerTest < ActionController::TestCase
        class Admin::QuotedTestableControllerTest < ActionController::TestCase
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_declarations(file)
      end
    end

    def test_convert_declarations_when_mailer_in_the_name
      rspec_in = <<~IT_SPEC
        RSpec.describe Admin::TestableMailer do
        RSpec.describe 'Admin::QuotedTestableMailer' do
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        class Admin::TestableMailerTest < ActionMailer::TestCase
        class Admin::QuotedTestableMailerTest < ActionMailer::TestCase
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_declarations(file)
      end
    end

    def test_convert_declarations_when_helper_in_the_name
      rspec_in = <<~IT_SPEC
        RSpec.describe Admin::TestableHelper do
        RSpec.describe 'Admin::QuotedTestableHelper' do
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        class Admin::TestableHelperTest < ActionView::TestCase
        class Admin::QuotedTestableHelperTest < ActionView::TestCase
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_declarations(file)
      end
    end

    def test_convert_declarations_when_in_the_requests_folder
      rspec_in = <<~IT_SPEC
        RSpec.describe 'some  name with spaces' do
        end
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        class SomeNameWithSpacesTest < ActionDispatch::IntegrationTest
        end
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in, dir: 'spec/requests') do |file|
        SpecConvertor.new(Command.new).convert_declarations(file)
      end
    end

    def test_convert_declarations_when_in_the_systems_folder
      rspec_in = <<~IT_SPEC
        RSpec.describe 'some  name with spaces' do
        end
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        class SomeNameWithSpacesTest < ApplicationSystemTestCase
        end
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in, dir: 'spec/systems') do |file|
        SpecConvertor.new(Command.new).convert_declarations(file)
      end
    end

    def test_convert_declarations_when_in_the_custom_folder
      rspec_in = <<~IT_SPEC
        RSpec.describe 'some  name with spaces' do
        end
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        class SomeNameWithSpacesTest < ActiveSupport::TestCase
        end
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in, dir: 'spec/carriers') do |file|
        SpecConvertor.new(Command.new).convert_declarations(file)
      end
    end

    def test_convert_declarations_when_there_is_comment_at_the_end
      rspec_in = <<~IT_SPEC
        RSpec.describe 'target' do # comment
        end
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        class TargetTest < ActiveSupport::TestCase # comment
        end
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_declarations(file)
      end
    end

    def test_convert_around
      rspec_in = <<~IT_SPEC
        around(:all) do |runner|
          runner.run
        end
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        skip 'TODO: Remove this skip when `around` will be migrated manually by replacing `run` with `call`'
        around(:all) do |runner|
          runner.run
        end
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        SpecConvertor.new(Command.new).convert_around(file)
      end
    end

    private

    def assert_capture(exp, input, dir: nil)
      if dir
        absolute_dir = File.join(Dir.tmpdir, 'test', dir)
        FileUtils.mkdir_p(absolute_dir)
      end

      snippet = Tempfile.create('', absolute_dir)
      snippet.puts input
      snippet.close

      yield(snippet.path)

      assert_equal exp, File.read(snippet.path)
    ensure
      File.unlink snippet.path
    end
  end
end
