# coding: utf-8
require_relative 'helper'

class TestExecutable < Test::Unit::TestCase

  class Exec
    include MultiExiftool::Executable
    def initialize
      super
    end
  end

  setup do
    @executable = Exec.new
  end

  test 'appending to filenames' do
    @executable.filenames << 'a.jpg'
    assert_equal %w(a.jpg), @executable.filenames
    @executable.filenames << 'b.jpg'
    assert_equal %W(a.jpg b.jpg), @executable.filenames
  end

end
