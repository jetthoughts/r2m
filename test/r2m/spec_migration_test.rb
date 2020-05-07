# frozen_string_literal: true

require 'test_helper'

require 'r2m/spec_migration'

module R2M
  class SpecMigrationTest < Minitest::Test
    def test_copy_sources_to_target_when_spec_provided
      Dir.mktmpdir do |tmpdir|
        FileUtils.cp_r(sample_app_path, tmpdir)
        sample_app_root = Pathname(tmpdir).join('sample_app')
        FileUtils.chdir(sample_app_root) do
          spec = sample_app_root.join('spec/example_spec.rb')

          SpecMigration.new(sample_app_root).migrate(spec)

          test = sample_app_root.join('test/example_test.rb')

          assert File.exist? test
        end
      end
    end

    def test_split_into_pathes_without_nested_folders
      absolute_spec_path = File.absolute_path(
        '../fixtures/sample_app/spec/example_spec.rb',
        __dir__
      )

      FileUtils.chdir sample_app_path do
        spec_relative_path, spec_basename = SpecMigration.new(sample_app_path).split_path(absolute_spec_path)

        assert_equal '.', spec_relative_path.to_s
        assert_equal 'example_spec.rb', spec_basename.to_s
      end
    end

    def test_split_into_pathes_with_nested_folders
      absolute_spec_path = File.absolute_path(
        '../fixtures/sample_app/spec/models/model_spec.rb',
        __dir__
      )

      FileUtils.chdir sample_app_path do
        spec_relative_path, spec_basename =
          SpecMigration.new(sample_app_path).split_path(absolute_spec_path)

        assert_equal 'models', spec_relative_path.to_s
        assert_equal 'model_spec.rb', spec_basename.to_s
      end
    end

    private

    def sample_app_path
      File.expand_path('../fixtures/sample_app', __dir__)
    end
  end
end
