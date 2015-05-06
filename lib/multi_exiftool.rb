# coding: utf-8
require_relative 'multi_exiftool/values'
require_relative 'multi_exiftool/reader'
require_relative 'multi_exiftool/writer'
require_relative 'multi_exiftool/copier'

module MultiExiftool

  # Reading metadata
  # Be aware: it returns an array of two elements:
  # values, errors
  #
  # Example:
  #   values, errors = MultiExiftool.read(Dir['*.jpg'])
  #   if errors.empty?
  #     values.each {|val| do_something_with(val) }
  #   else
  #     # error handling
  #   end
  def self.read(filenames, opts={})
    reader = Reader.new
    reader.filenames = filenames
    if val = opts.delete(:tags)
      reader.tags = val
    end
    if val = opts.delete(:group)
      reader.group = val
    end
    reader.options = opts unless opts.empty?
    values = reader.read
    [values, reader.errors]
  end

  # Writing metadata
  # Returns an array of the error messages
  #
  # Example:
  #   errors = MultiExiftool.write(Dir['*.jpg'], {author: 'Jan Friedrich'})
  #   unless errors.empty?
  #     # do error handling
  #   end
  def self.write(filenames, values, opts={})
    writer = Writer.new
    writer.filenames = filenames
    writer.values = values
    writer.options = opts unless opts.empty?
    writer.write
    writer.errors
  end

  class Error < ::StandardError; end

  @exiftool_command = 'exiftool'

  class << self

    attr_accessor :exiftool_command
    attr_reader :exiftool_version

    def exiftool_command= cmd
      @exiftool_command = cmd
      @exiftool_version = nil
    end

    # Exiftool version as float (since exiftool versions
    # are numbered "float friendly")
    def exiftool_version
      @exiftool_version ||= `#{exiftool_command} -ver`.to_f
    end

  end

end

