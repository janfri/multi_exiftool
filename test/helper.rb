# coding: utf-8
require_relative '../lib/multi_exiftool'
require 'test/unit'
require 'contest'
require 'open3'
require 'stringio'
require 'yaml'

module TestHelper

  @@fixtures = YAML.load_file('test/fixtures.yml')

  def use_fixture(name, &block)
    @fixture = @@fixtures[name]
    if @fixture.nil?
      assert false, "Fixture #{name} not found!\n" << caller.first
    end
    mocking_open3(name, @fixture['stdout'], @fixture['stderr'], &block)
  end

  def mocking_open3(command, outstr, errstr, &block)
    executed = {exec: false}
    open3_eigenclass = class << Open3; self; end
    open3_eigenclass.module_exec(command, outstr, errstr, executed) do |cmd, out, err, exec|
      define_method :popen3 do |arg|
        exec[:exec] = true
        if arg == cmd
          return [nil, StringIO.new(out), StringIO.new(err)]
        else
          raise ArgumentError.new("Expected call of Open3.popen3 with argument #{cmd.inspect} but was #{arg.inspect}.")
        end
      end
    end
    begin
      yield
    rescue ArgumentError => e
      assert false, e.message
    end
    assert executed[:exec], "Open3.popen3 not executed!\n" << caller[0,2].inspect
  end

end

class Test::Unit::TestCase
  include TestHelper
end
