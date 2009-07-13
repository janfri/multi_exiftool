require_relative 'executable'

module MultiExiftool

  class Reader

    MANDATORY_ARGS = %w(-J)

    attr_accessor :tags

    include Executable

    def command
      cmd = [exiftool_command]
      cmd << MANDATORY_ARGS
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

  end

end
