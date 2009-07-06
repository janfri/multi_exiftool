require 'shellwords'

module MultiExiftool

  module Executable

    attr_accessor :exiftool_command, :errors

    def initialize
      @exiftool_command = 'exiftool'
    end

    def execute
      @errors = []
      %x(#{command})
    end

    private

    def shelljoin *args
      Shellwords.shelljoin(args.flatten)
    end

  end

end
