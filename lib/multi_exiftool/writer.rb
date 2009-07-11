require_relative 'executable'

module MultiExiftool

  class Writer

    attr_accessor :filenames, :values

    include Executable

    def command
     [exiftool_command, values_opts, escaped_filenames].flatten.join(' ')
    end

    private

    def values_opts
      raise MultiExiftool::Error.new('No values.') unless @values
      @values.map {|tag, val| "-#{tag}=#{escape(val.to_s)}"}
    end

  end

end
