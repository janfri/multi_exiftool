# encoding: utf-8
# frozen_string_literal: true

require_relative 'multi_exiftool/options'
require_relative 'multi_exiftool/reader'
require_relative 'multi_exiftool/writer'
require_relative 'multi_exiftool/batch'

module MultiExiftool

  VERSION = '0.19.0'

  @exiftool_command = 'exiftool'

  class << self

    # Reading metadata
    # Be aware: it returns an array of two elements:
    # values, errors
    #
    # Example:
    #   values, messages = MultiExiftool.read(Dir['*.jpg'])
    #   if messages.errors_or_warnings?
    #     # error handling
    #   else
    #     values.each {|val| do_something_with(val) }
    #   end
    def read filenames, tags: nil, **opts
      reader = Reader.new(filenames, tags: tags, **opts)
      values = reader.read
      [values, reader.messages]
    end

    # Writing metadata
    # Returns an array of the error messages
    #
    # Example:
    #   messages = MultiExiftool.write(Dir['*.jpg'], {author: 'Jan Friedrich'})
    #   if messages.errors_or_warnings?
    #     # do error handling
    #   end
    def write filenames, values, **opts
      writer = Writer.new(filenames, values, **opts)
      writer.write
      writer.messages
    end

    # Deleting metadata
    # Returns an array of the error messages
    #
    # Examples:
    #   # delete values for all tags
    #   messages = MultiExiftool.delete_values(Dir['*.jpg'])
    #   if messages.errors_or_warnings?
    #     # do error handling
    #   end
    #
    #   # delete values for tags Author and Title
    #   messages = MultiExiftool.delete_values(Dir['*.jpg'], %w[author title])
    #   if messages.errors_or_warnings?
    #     # do error handling
    #   end
    def delete_values filenames, tags: :all
      values = Array(tags).inject(Hash.new) {|h,tag| h[tag] = nil; h}
      write(filenames, values)
    end


    # Execute a batch of write commands
    # Returns an array of the error messages
    #
    # Example:
    #   messages = MultiExiftool.batch do
    #     Dir['*.jpg'].each_with_index do |filename, i|
    #       write filename, {author: 'Jan Friedrich', comment: "This is file number #{i+1}."}
    #     end
    #   if messages.errors_or_warnings?
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
      batch.messages
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

    # :nodoc:

    # Converts a name to a unified name by converting it with to_s and
    # downcasing it
    def unify name
      name.to_s.downcase
    end

    # Converts a name to a unified name by converting it with to_s and removing
    # underscores and downcasing it
    def unify2 name
      name.to_s.gsub('_', '').downcase
    end

  end

  class Error < ::StandardError; end

end

