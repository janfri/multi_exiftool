# coding: utf-8
require 'open3'
require 'shellwords'

module MultiExiftool

  module Executable

    attr_accessor :exiftool_command, :errors, :numerical
    attr_writer :options, :filenames

    def initialize
      @exiftool_command = 'exiftool'
      @options = {}
    end

    def options
      opts = @options.dup
      opts[:n] = true if @numerical
      opts
    end

    def filenames
      Array(@filenames)
    end

    def escaped_filenames
      raise MultiExiftool::Error.new('No filenames.') if filenames.empty?
      @filenames.map { |fn| Shellwords.escape(fn) }
    end

    def execute
      prepare_execution
      execute_command
      parse_results
    end

    private

    def escape str
      Shellwords.escape(str)
    end

    def options_args
      opts = options
      return [] if opts.empty?
      opts.map do |opt, val|
        if val == true
          "-#{opt}"
        else
          "-#{opt} #{val}"
        end
      end
    end

    def prepare_execution
      @errors = []
    end

    def execute_command
      stdin, @stdout, @stderr = Open3.popen3(command)
    end

  end

end
