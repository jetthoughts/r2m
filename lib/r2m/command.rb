# frozen_string_literal: true

require 'thor'
require 'pathname'

require_relative './spec_convector'
require_relative './spec_migration'

module R2M
  # Adds CLI commands convert and migrate
  #   bin/r2m convert
  class Command < Thor
    include Thor::Actions

    default_command :convert

    def self.exit_on_failure?
      true
    end

    desc 'convert [path1 path2 ...]', 'Convert Rspec to minitest'
    def convert(*paths)
      files(paths.flatten).each { |path| run_convert path }
    end

    desc 'migrate [path1 path2 ...]', 'Move found specs to test folder and convert them'
    method_option(
      :replace_suffix,
      desc: 'Renames *_spec.rb to *_test.rb',
      default: true,
      aliases: ['s'],
      type: :boolean
    )
    def migrate(*paths)
      setup_rails_to_run_minitest

      files(paths.flatten).each do |path|
        say "Processing #{path}"
        migrated_path = run_migrate(path)
        run_convert(migrated_path)
      end
    end

    private

    def setup_rails_to_run_minitest
      path_to_rails_template = File.expand_path('../../template.rb', __dir__)
      system("DISABLE_SPRING=1 rails app:template LOCATION=#{path_to_rails_template}")
    end

    def run_migrate(path)
      SpecMigration.new(Pathname.pwd).migrate(File.realpath(path))
    end

    def run_convert(file)
      say "Processing #{file}"
      SpecConvector.new(self).process(file.to_s)
    end

    def files(paths)
      paths = Array(paths)
      return Dir.glob('spec/**/*_spec.rb') if paths.empty?

      paths.map do |path|
        if File.exist?(path) && !File.directory?(path)
          path
        elsif Dir.exist?(path)
          Dir.glob(File.join(path, '**', '*_spec.rb'))
        else
          Dir.glob(path)
        end
      end.flatten
    end
  end
end
