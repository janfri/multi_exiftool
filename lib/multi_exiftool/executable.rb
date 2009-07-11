require 'shellwords'

module MultiExiftool

  module Executable

    attr_accessor :exiftool_command, :errors

    def initialize
      @exiftool_command = 'exiftool'
    end

    def escaped_filenames
      raise MultiExiftool::Error.new('No filenames.') unless @filenames
      @filenames.map { |fn| Shellwords.escape(fn) }
    end

    def execute
      @errors = []
      %x(#{command})
    end

    private

    def escape str
      Shellwords.escape(str)
    end

  end

end
