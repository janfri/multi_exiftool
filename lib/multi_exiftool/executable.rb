# encoding: utf-8
# frozen_string_literal: true

require 'open3'

module MultiExiftool

  # Mixin for Reader and Writer.
  module Executable

    attr_reader :errors
    attr_accessor :filenames, :numerical, :options

    def initialize
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

    def exiftool_command
      MultiExiftool.exiftool_command
    end

    def options_args
      opts = options
      return [] if opts.empty?
      opts.map do |opt, val|
        arg = @option_mapping[opt] || opt
        if val == true
          "-#{arg}"
        else
          %W[-#{arg} #{val}]
        end
      end
    end

    def prepare_execution
      @errors = []
    end

    def execute_command
      stdin, @stdout, @stderr = Open3.popen3(exiftool_command, '-@', '-')
      exiftool_args.each do |part|
        stdin << part
        stdin << "\n"
      end
      stdin.close
    end

  end

end
