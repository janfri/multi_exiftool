# coding: utf-8
require_relative 'writer'

module MultiExiftool

  # Handle copying of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # possible errors.
  #
  # c = Copier.new
  # c.copy_values_from = 'file.jpg'
  # c.copy_values_from = {'file.jpg' => 'exif:all'}
  # c.copy_values_from = {'file.jpg' => 'title', 'file2.jpg' => 'author'}
  class Copier < Writer

    attr_accessor :copy_values_from

    def initialize
      super
      @copy_values_from = []
    end


    # Getting the command-line arguments which would be executed
    # when calling #copy. It could be useful for logging, debugging or
    # maybe even for creating a batch-file with exiftool command to be
    # processed.
    def exiftool_args
      super
      fail MultiExiftool::Error, 'No copy_values_from.' if copy_values_from.empty?
      cmd = []
      cmd << Writer.mandatory_args
      cmd << options_args
      cmd << tags_from_file_args
      cmd << values_args
      cmd << filenames
      cmd.flatten
    end

    alias write execute # :nodoc:

    private

    def tags_from_file_args
      case @copy_values_from
      when Hash
        @copy_values_from.map {|k,v| ['-tagsfromfile', k.to_s, "-#{v}"]}.flatten
      else
        ['-tagsfromfile', @copy_values_from.to_s]
      end
    end

  end

end
