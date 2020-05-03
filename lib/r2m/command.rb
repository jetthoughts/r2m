# frozen_string_literal: true

require 'thor'
require_relative './spec_convertor'

module R2M
  # Adds CLI commands convert and migrate
  #   bin/r2m convert
  class Command < Thor
    include Thor::Actions

    default_command :convert

    def self.exit_on_failure?
      true
    end

    desc 'convert [path...]', 'Convert Rspec to minitest'

    def convert(pathes)
      files(pathes).each { |file| process file }
    end

    desc 'migrate [path...]', 'Move found specs to test folder and convert them'
    method_option :replace_suffix,
      desc: 'Renames *_spec.rb to *_test.rb',
      default: true,
      aliases: ['s'],
      type: :boolean

    def migrate(pathes)
      pp files(pathes)
    end

    private

    def process(file)
      SpecConvertor.new(self).process(file)
    end

    def files(pathes)
      Array(pathes).map do |path|
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
