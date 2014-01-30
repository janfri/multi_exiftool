# coding: utf-8
require 'open3'
require 'shellwords'

module MultiExiftool

  # Mixin for Reader and Writer.
  module Executable

    attr_reader :filenames
    attr_accessor :exiftool_command, :errors, :numerical
    attr_writer :options

    def initialize
      @exiftool_command = 'exiftool'
      @options = {}
      @filenames = []
      @option_mapping = {numerical: :n}
    end

    def options
      opts = @options.dup
      opts[:n] = true if @numerical
      opts
    end

    def filenames= value
      @filenames = Array(value)
    end

    def execute # :nodoc:
      prepare_execution
      execute_command
      parse_results
    end

    private

    def escape str
      Shellwords.escape(str.to_s)
    end

    def escaped_filenames
      raise MultiExiftool::Error.new('No filenames.') if filenames.empty?
      filenames.map { |fn| Shellwords.escape(fn) }
    end

    def options_args
      opts = options
      return [] if opts.empty?
      opts.map do |opt, val|
        arg = @option_mapping[opt] || opt
        if val == true
          "-#{arg}"
        else
          "-#{arg} #{val}"
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
