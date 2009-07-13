require_relative 'executable'

module MultiExiftool

  class Reader

    MANDATORY_ARGS = %w(-J)

    include Executable

    def command
      cmd = [exiftool_command]
      cmd << MANDATORY_ARGS
      cmd << escaped_filenames
      cmd.flatten.join(' ')
    end

    alias read execute

  end

end
