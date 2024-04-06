# encoding: utf-8
# frozen_string_literal: true

require_relative 'executable'

module MultiExiftool

  # Handle writing of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # possible errors.
  class Writer

    attr_accessor :values

    include Executable

    def initialize filenames=[], values={}, **options
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
      cmd << values_args
      cmd << filenames
      cmd.flatten
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
          res << val.map {|v| "#{tag}=#{v}"}
        else
          res << "#{tag}=#{val}"
        end
      end
      res.flatten
    end

  end

end
