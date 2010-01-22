# coding: utf-8
require_relative 'helper'

class TestWriterGroups < Test::Unit::TestCase

  setup do
    @writer = MultiExiftool::Writer.new
    @writer.filenames = %w(a.jpg b.bmp c.tif)
  end

  test 'simple case' do
    @writer.values = {:exif => {:comment => 'test'}  }
    command = 'exiftool -exif:comment=test a.jpg b.bmp c.tif'
    assert_equal command, @writer.command
  end

end
