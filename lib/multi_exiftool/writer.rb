# coding: utf-8
require_relative 'executable'

module MultiExiftool

  # Handle writing of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # possible errors.
  class Writer

    attr_accessor :overwrite_original, :values

    include Executable

    def initialize
      super
      @values = {}
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
      values_to_param_array(@values).map {|arg| "-#{arg}"}
    end

    def values_to_param_array hash
      res = []
      hash.each do |tag, val|
        if val.respond_to? :to_hash
          res << values_to_param_array(val.to_hash).map {|arg| "#{tag}:#{arg}"}
        elsif val.respond_to? :to_ary
          res << val.map {|v| "#{tag}=#{escape(v)}"}
        else
          res << "#{tag}=#{escape(val)}"
        end
      end
      res.flatten
    end

    def parse_results
      @errors = @stderr.read.split(/\n/)
      @errors.empty?
    end

  end

end
