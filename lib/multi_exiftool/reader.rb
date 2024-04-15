# encoding: utf-8
# frozen_string_literal: true

require_relative 'executable'
require_relative 'reader_values'
require 'json'

module MultiExiftool

  # Handle reading of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # the results as well as possible errors.
  class Reader

    attr_accessor :tags

    include Executable

    def initialize filenames=[], tags: nil, **options
      super(filenames, **options)
      self.tags = tags
    end

    def self.mandatory_args
      %w(-J -charset FileName=utf8 -charset utf8)
    end

    # Getting the command-line arguments which would be executed
    # when calling #read. It could be useful for logging, debugging or
    # maybe even for creating a batch-file with exiftool command to be
    # processed.
    def exiftool_args
      fail MultiExiftool::Error, 'No filenames.' if filenames.empty?
      cmd = []
      cmd << Reader.mandatory_args
      cmd << options.options_args
      cmd << tags_args
      cmd << filenames
      cmd.flatten
    end

    alias read execute # :nodoc:

    def tags= value
      @tags = Array(value)
    end

    private

    def tags_args
      return [] unless @tags
      @tags.map {|tag| "-#{tag}"}
    end

    def parse_results
      stdout = @stdout.read
      parse_messages
      json = JSON.parse(stdout)
      json.map {|values| ReaderValues.new(values)}
    rescue JSON::ParserError
      return []
    end

  end

end
