# coding: utf-8
require_relative 'executable'

module MultiExiftool

  class Writer

    attr_reader :overwrite_original
    attr_writer :values

    include Executable

    def values
      Array(@values)
    end

    def command
      cmd = [exiftool_command]
      cmd << options_args
      cmd << values_args
      cmd << escaped_filenames
      cmd.flatten.join(' ')
    end

    def overwrite_original= bool
      @options[:overwrite_original] = !!bool
    end

    alias write execute

    private

    def values_args
      raise MultiExiftool::Error.new('No values.') if values.empty?
      @values.map {|tag, val| "-#{tag}=#{escape(val.to_s)}"}
    end

    def parse_results
      @errors = @stderr.readlines
      @errors.empty?
    end

  end

end
