# coding: utf-8
require_relative 'executable'
require 'json'

module MultiExiftool

  # Handle reading of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # the results as well as possible errors.
  class Reader

    MANDATORY_ARGS = %w(-J)

    attr_accessor :tags, :group

    include Executable

    def initialize
      super
      @option_mapping.merge! group: :g
    end

    # Options to use with the exiftool command.
    def options
      opts = super
      if @group
        opts[:g] = @group
      end
      opts
    end

    # Getting the command for the command-line which would be executed
    # when calling #read. It could be useful for logging, debugging or
    # maybe even for creating a batch-file with exiftool command to be
    # processed.
    def command
      fail MultiExiftool::Error, 'No filenames.' if filenames.empty?
      cmd = [exiftool_command]
      cmd << MANDATORY_ARGS
      cmd << options_args
      cmd << tags_args
      cmd << filenames
      cmd.flatten
    end

    alias read execute # :nodoc:

    private

    def tags_args
      return [] unless @tags
      @tags.map {|tag| "-#{tag}"}
    end

    def parse_results
      stdout = @stdout.read
      error_string = @stderr.read.gsub(/^ .*$/, '')
      @errors = error_string.split(/\n/)
      json = JSON.parse(stdout)
      json.map {|values| Values.new(values)}
    rescue JSON::ParserError
      return []
    end

  end

end
