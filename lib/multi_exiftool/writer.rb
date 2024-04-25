# encoding: utf-8
# frozen_string_literal: true

require_relative 'executable'
require_relative 'writer_values'

module MultiExiftool

  # Handle writing of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # possible errors.
  class Writer

    attr_accessor :values

    include Executable

    def initialize filenames=[], values=nil, **vals_and_opts
      if values
        options = vals_and_opts
      else
        options = Options.new
        values = {}
        vals_and_opts.each_pair do |k, v|
          if options.respond_to? k
            options[k] = v
          else
            values[k] = v
          end
        end
      end
      super(filenames, **options)
      self.values = values
    end

    def self.mandatory_args
      %w(-charset FileName=utf8 -charset utf8)
    end

    # Getting the command-line arguments which would be executed
    # when calling #write. It could be useful for logging, debugging or
    # maybe even for creating a batch-file with exiftool command to be
    # processed.
    def exiftool_args
      fail MultiExiftool::Error, 'No filenames.' if filenames.empty?
      cmd = []
      cmd << Writer.mandatory_args
      cmd << options.options_args
      cmd << values.values_args
      cmd << filenames
      cmd.flatten
    end

    alias write execute # :nodoc:

    alias vals values
    alias vals= values=

    def values= vals
      unless vals.kind_of? WriterValues
        vals = WriterValues.new(vals)
      end
      @values = vals
    end

  end

end
