require_relative 'executable'

module MultiExiftool

  class Writer

    attr_accessor :filenames, :values

    include Executable

    def command
     [exiftool_command, values_opts, shelljoin(filenames)].join(' ') 
    end

    private

    def values_opts
      @values.map {|tag, val| "-#{tag}=#{shelljoin(val.to_s)}"}
    end

  end

end
