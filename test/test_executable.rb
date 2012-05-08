# coding: utf-8
require_relative 'helper'

class TestExecutable < Test::Unit::TestCase

  setup do
    @executable = Object.new
    @executable.extend MultiExiftool::Executable
  end

  test 'appending to filenames' do
    @executable.filenames << 'a.jpg'
    assert_equal %w(a.jpg), @executable.filenames
    @executable.filenames << 'b.jpg'
    assert_equal %W(a.jpg b.jpg), @executable.filenames
  end

end
