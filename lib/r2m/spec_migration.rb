# frozen_string_literal: true

require 'rake/file_utils'

class SpecMigration # rubocop:todo Style/Documentation
  def initialize(basedir)
    @basedir = Pathname(basedir)
  end

  def migrate(spec_file) # rubocop:todo Metrics/AbcSize
    move_and_rename_spec_to_test(spec_file)
  end

  def split_path(file)
    spec_root = @basedir / 'spec'
    dirname, basename = Pathname(file).split
    relative_path = dirname.relative_path_from(spec_root)

    [relative_path, basename]
  end

  def move_and_rename_spec_to_test(spec_file)
    relative_path, spec_basename = split_path(spec_file)
    test_root = @basedir / 'test'

    test_dirname = test_root + relative_path
    FileUtils.mkdir_p test_dirname

    test_basename = spec_basename.sub(/_spec(?=\.rb)/, '_test')
    test_file = test_dirname + test_basename
    FileUtils.cp spec_file, test_file unless test_file.exist?

    test_file
  end
end
