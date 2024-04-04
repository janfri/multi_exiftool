# encoding: utf-8
# frozen_string_literal: true

require_relative 'multi_exiftool/values'
require_relative 'multi_exiftool/reader'
require_relative 'multi_exiftool/writer'
require_relative 'multi_exiftool/batch'

module MultiExiftool

  VERSION = '0.18.0'

  @exiftool_command = 'exiftool'

  class << self

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
    def read filenames, opts={}
      reader = Reader.new(filenames, opts)
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
    def write filenames, values, opts={}
      writer = Writer.new(filenames, values, opts)
      writer.write
      writer.errors
    end

    # Deleting metadata
    # Returns an array of the error messages
    #
    # Examples:
    #   # delete values for all tags
    #   errors = MultiExiftool.delete_values(Dir['*.jpg'])
    #   unless errors.empty?
    #     # do error handling
    #   end
    #
    #   # delete values for tags Author and Title
    #   errors = MultiExiftool.delete_values(Dir['*.jpg'], %w[author title])
    #   unless errors.empty?
    #     # do error handling
    #   end
    def delete_values filenames, opts={}
      tags = opts.fetch(:tags, :all)
      values = Array(tags).inject(Hash.new) {|h,tag| h[tag] = nil; h}
      write(filenames, values)
    end


    # Execute a batch of write commands
    # Returns an array of the error messages
    #
    # Example:
    #   errors = MultiExiftool.batch do
    #     Dir['*.jpg'].each_with_index do |filename, i|
    #       write filename, {author: 'Jan Friedrich', comment: "This is file number #{i+1}."}
    #     end
    #   unless errors.empty?
    #     # do error handling
    #   end
    def batch &block
      batch = Batch.new
      if block.arity == 0
        batch.instance_exec &block
      else
        yield batch
      end
      batch.execute
      batch.errors
    end

    attr_accessor :exiftool_command
    attr_reader :exiftool_version

    def exiftool_command= cmd
      @exiftool_command = cmd
      @exiftool_version = nil
    end

    # ExifTool version as float (since exiftool versions
    # are numbered "float friendly")
    def exiftool_version
      @exiftool_version ||= `#{exiftool_command} -ver`.to_f
    end

  end

  class Error < ::StandardError; end

end

