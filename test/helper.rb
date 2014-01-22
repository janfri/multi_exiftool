# coding: utf-8
require_relative '../lib/multi_exiftool'
require 'test/unit'
require 'contest'
require 'open3'
require 'stringio'
require 'yaml'

module TestHelper

  @@fixtures = YAML.load_file('test/fixtures.yml')

  def use_fixture(name)
    @fixture = @@fixtures[name]
    mocking_open3(name, @fixture['stdout'], @fixture['stderr'])
  end

  def mocking_open3(command, outstr, errstr)
    open3_eigenclass = class << Open3; self; end
    open3_eigenclass.module_exec(command, outstr, errstr) do |cmd, out, err|
      define_method :popen3 do |arg|
        if arg == cmd
          return [nil, StringIO.new(out), StringIO.new(err)]
        else
          raise ArgumentError.new("Expected call of Open3.popen3 with argument #{cmd.inspect} but was #{arg.inspect}.")
        end
      end
    end
  end

end

class Test::Unit::TestCase
  include TestHelper
end
