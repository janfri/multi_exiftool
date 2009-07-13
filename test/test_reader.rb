require_relative '../lib/multi_exiftool'
require 'test/unit'

class TestReader < Test::Unit::TestCase

  def setup
    @reader = MultiExiftool::Reader.new
  end

  def test_simple_case
    @reader.filenames = %w(a.jpg b.tif c.bmp)
    command = 'exiftool -J a.jpg b.tif c.bmp'
    assert_equal command, @reader.command
  end

  def test_no_filenames
    assert_raises MultiExiftool::Error do
      @reader.command
    end
  end

  def test_filenames_with_spaces
    @reader.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
    command = 'exiftool -J one\ file\ with\ spaces.jpg another\ file\ with\ spaces.tif'
    assert_equal command, @reader.command
  end

end
