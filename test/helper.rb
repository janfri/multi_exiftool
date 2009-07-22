require_relative '../lib/multi_exiftool'
require 'test/unit'
require 'open3'
require 'stringio'

module TestHelper

  def mocking_open3(command, outstr, errstr)
    Open3.module_exec(command, outstr, errstr) do |cmd, out, err|
      @cmd, @out, @err = cmd, out, err
      def self.popen3(command)
        if command == @cmd
          return [nil, StringIO.new(@out), StringIO.new(@err)]
        else
          raise ArgumentError
        end
      end
    end
  end

end

class Test::Unit::TestCase
  include TestHelper
end

class Test::Unit::TestCase
  include TestHelper
end
