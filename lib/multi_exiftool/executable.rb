# encoding: utf-8
# frozen_string_literal: true

require 'open3'

require_relative 'messages'

module MultiExiftool

  # Mixin for Reader and Writer.
  module Executable

    attr_reader :messages
    attr_accessor :config, :filenames, :numerical, :options

    def initialize filenames=[], options={}
      @options = options
      @filenames = filenames
      @option_mapping = {numerical: :n}
      if val = options.delete(:config)
        @config = val
      end
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
      @messages = Messages.new([])
    end

    def execute_command
      args = ['-@', '-']
      if @config
        args = ['-config', @config] + args
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
