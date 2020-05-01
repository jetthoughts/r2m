
require 'thor'

module R2M
  class Command < Thor
    include Thor::Actions

    default_command :convert
    argument :path, default: 'spec'

    def self.exit_on_failure?
      true
    end

    desc 'convert', 'Convert Rspec to MiniTest'

    def convert
      files.each { |file| process file }
    end

    private

    def process(file)
      Processor.new(self).process(file)
    end

    def files
      if Dir.exist?(path)
        Dir.glob(File.join(path, '**', '*_test.rb'))
      else
        Dir.glob(path)
      end
    end
  end
end
