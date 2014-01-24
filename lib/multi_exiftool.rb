# coding: utf-8
require_relative 'multi_exiftool/values'
require_relative 'multi_exiftool/reader'
require_relative 'multi_exiftool/writer'

module MultiExiftool

  def self.read(filenames, opts={})
    reader = Reader.new
    reader.filenames = filenames
    [:group, :numerical, :tags].each do |p|
      if val = opts.delete(p)
        reader.send(p.to_s + '=', val)
      end
    end
    reader.options = opts unless opts.empty?
    values = reader.read
    [values, reader.errors]
  end

  class Error < ::StandardError; end

end

