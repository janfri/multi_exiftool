# coding: utf-8
require_relative 'executable'

module MultiExiftool

  # Handle writing of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # possible errors.
  class Writer

    attr_accessor :overwrite_original
    attr_writer :values

    include Executable

    def values
      Array(@values)
    end

    # Options to use with the exiftool command.
    def options
      opts = super
      opts[:overwrite_original] = true if @overwrite_original
      opts
    end

    # Getting the command for the command-line which would be executed
    # when calling #write. It could be useful for logging, debugging or
    # maybe even for creating a batch-file with exiftool command to be
    # processed.
    def command
      cmd = [exiftool_command]
      cmd << options_args
      cmd << values_args
      cmd << escaped_filenames
      cmd.flatten.join(' ')
    end

    alias write execute # :nodoc:

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
