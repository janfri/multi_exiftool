# encoding: utf-8
# frozen_string_literal: true

require 'open3'
require 'ostruct'

module MultiExiftool

  # Mixin for Reader and Writer.
  module Executable

    attr_reader :errors
    attr_accessor :config, :filenames, :options

    def initialize filenames=[], options={}
      self.options = options
      self.filenames = filenames
      if val = options.delete(:config)
        self.config = val
      end
    end

    def options= opts
      @options = OpenStruct.new(opts)
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

    def pimped_options
      opts = @options.to_h
      if opts.delete(:numerical)
        opts[:n] = true
      end
      opts
    end


    def exiftool_command
      MultiExiftool.exiftool_command
    end

    def options_args
      opts = pimped_options
      return [] if opts.empty?
      opts.map do |arg, val|
        case val
        when true
          "-#{arg}"
        when false, nil
          ''
        else
          %W[-#{arg} #{val}]
        end
      end
    end

    def prepare_execution
      @errors = []
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
      parse_errors
      @errors.empty?
    end

    def parse_errors
      @errors = @stderr.read.lines(chomp: true).select {|l| l =~ /^(Error|Warning):/}
    end

  end

end
