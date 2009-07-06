require_relative '../lib/multi_exiftool/writer'
require 'test/unit'

class TestWriter < Test::Unit::TestCase

  def setup
    @writer = MultiExiftool::Writer.new
  end

  def test_simple_case
    @writer.filenames = %w(a.jpg b.tif c.bmp)
    @writer.values = {:author => 'janfri'}
    command = 'exiftool -author=janfri a.jpg b.tif c.bmp'
    assert_equal command, @writer.command
  end

  def test_tags_with_space_values
    @writer.filenames = %w(a.jpg b.tif c.bmp)
    @writer.values = {:author => 'janfri', :comment => 'some comment'}
    command = 'exiftool -author=janfri -comment=some\ comment a.jpg b.tif c.bmp'
    assert_equal command, @writer.command
  end

  def test_filenames_with_tags
    @writer.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
    @writer.values = {:author => 'janfri'}
    command = 'exiftool -author=janfri one\ file\ with\ spaces.jpg another\ file\ with\ spaces.tif'
    assert_equal command, @writer.command
  end

end
