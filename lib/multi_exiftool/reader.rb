# coding: utf-8
require_relative 'executable'
require 'json'

module MultiExiftool

  class Reader

    MANDATORY_ARGS = %w(-J)

    attr_accessor :tags, :group

    include Executable

    def options
      opts = super
      if @group
        opts["g#{@group}"] = true
      end
      opts
    end

    def command
      cmd = [exiftool_command]
      cmd << MANDATORY_ARGS
      cmd << options_args
      cmd << tags_args
      cmd << escaped_filenames
      cmd.flatten.join(' ')
    end

    alias read execute

    private

    def tags_args
      return [] unless @tags
      @tags.map {|tag| "-#{tag}"}
    end

    def parse_results
      stdout = @stdout.read
      @errors = @stderr.readlines
      json = JSON.parse(stdout)
      json.map {|data| Data.new(data)}
    rescue JSON::ParserError
      return []
    end

  end

end
