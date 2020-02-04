# encoding: utf-8
# frozen_string_literal: true

require_relative 'executable'

module MultiExiftool

  # Allow to define a batch for different writing operations as one call of the
  # ExifTool command-line application
  class Batch

    include Executable

    # Define batch operation inside a block
    def initialize &blk
      @writers = []
      instance_exec &blk if block_given?
    end

    # Define a write operation for the batch.
    def write filenames, values, options={}
      w = MultiExiftool::Writer.new(filenames, values, options)
      @writers << w
    end

    # Getting the command-line arguments which would be executed
    # when calling #write. It could be useful for logging, debugging or
    # whatever.
    def exiftool_args
      @writers.map {|w| w.exiftool_args + ['-execute']}.flatten
    end

    private

    def parse_results
      @errors = @stderr.read.split(/\n/)
      @errors.empty?
    end

  end

end
