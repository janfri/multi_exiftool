# coding: utf-8
require_relative 'multi_exiftool/values'
require_relative 'multi_exiftool/reader'
require_relative 'multi_exiftool/writer'

module MultiExiftool

  def self.read(filenames, opts={})
    reader = Reader.new
    reader.filenames = filenames
    if val = opts.delete(:tags)
      reader.tags = val
    end
    reader.options = opts unless opts.empty?
    values = reader.read
    [values, reader.errors]
  end

  def self.write(filenames, values, opts={})
    writer = Writer.new
    writer.filenames = filenames
    writer.values = values
    writer.options = opts unless opts.empty?
    writer.write
    writer.errors
  end

  class Error < ::StandardError; end

end

