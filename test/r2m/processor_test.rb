# frozen_string_literal: true

require 'test_helper'

require 'r2m/command'
require 'r2m/processor'

module R2M
  class ProcessorTest < Minitest::Test
    def test_convert_it_to_methods
      rspec_in = <<~IT_SPEC
        it 'converts it"s to test method with # support' do
          assert true
        end
      IT_SPEC

      minitest_exp = <<~MINITEST_TEST
        def test_converts_it_s_to_test_method_with_support
          assert true
        end
      MINITEST_TEST

      assert_capture(minitest_exp, rspec_in) do |file|
        Processor.new(Command.new).convert_it_to_methods(file)
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
        Processor.new(Command.new).convert_mather_be_empty(file)
      end
    end

    private

    def assert_capture(exp, input)
      snippet = Tempfile.create
      snippet.puts input
      snippet.close

      yield(snippet.path)

      assert_equal exp, File.read(snippet.path)
    ensure
      File.unlink snippet.path
    end
  end
end
