# encoding: utf-8
# frozen_string_literal: true

require_relative 'options'
require 'open3'

require_relative 'messages'

module MultiExiftool

  # Mixin for Reader and Writer.
  module Executable

    attr_reader :messages
    attr_accessor :filenames, :options

    def initialize filenames=[], **options
      self.options = options
      self.filenames = filenames
    end

    def options= opts
      unless opts.kind_of? Options
        opts = Options.new(opts)
      end
      @options = opts
    end

    def filenames= value
      @filenames = Array(value)
    end

    def execute # :nodoc:
      prepare_execution
      execute_command
      parse_results
    end

    alias opts options

    private

    def exiftool_command
      MultiExiftool.exiftool_command
    end

    def prepare_execution
      @messages = Messages.new([])
    end

    def execute_command
      args = ['-@', '-']
      if c = @options.config
        args = ['-config', c] + args
      end
      stdin, @stdout, @stderr = Open3.popen3(exiftool_command, *args)
      exiftool_args.each do |part|
        stdin << part
        stdin << "\n"
      end
      stdin.close
    end

    def parse_results
      parse_messages
      !@messages.errors_or_warnings?
    end

    def parse_messages
      @messages = Messages.new(@stderr.read.lines(chomp: true))
    end

  end

end
