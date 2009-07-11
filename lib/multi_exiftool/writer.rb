require_relative 'executable'

module MultiExiftool

  class Writer

    attr_accessor :filenames, :options, :values

    include Executable

    def command
      cmd = [exiftool_command]
      cmd << options_args
      cmd << values_args
      cmd << escaped_filenames
      cmd.flatten.join(' ')
    end

    private

    def options_args
      return [] unless @options
      @options.map {|opt, val| "-#{opt}"}
    end

    def values_args
      raise MultiExiftool::Error.new('No values.') unless @values
      @values.map {|tag, val| "-#{tag}=#{escape(val.to_s)}"}
    end

  end

end
