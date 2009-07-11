require_relative '../lib/multi_exiftool'
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

  def test_no_filenames
    @writer.values = {:author => 'janfri'}
    assert_raises MultiExiftool::Error do
      @writer.command
    end
  end

  def test_no_values
    @writer.filenames = %w(a.jpg b.tif c.bmp)
    assert_raises MultiExiftool::Error do
      @writer.command
    end
  end

  def test_tags_with_space_values
    @writer.filenames = %w(a.jpg b.tif c.bmp)
    @writer.values = {:author => 'janfri', :comment => 'some comment'}
    command = 'exiftool -author=janfri -comment=some\ comment a.jpg b.tif c.bmp'
    assert_equal command, @writer.command
  end

  def test_filenames_with_spaces
    @writer.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
    @writer.values = {:author => 'janfri'}
    command = 'exiftool -author=janfri one\ file\ with\ spaces.jpg another\ file\ with\ spaces.tif'
    assert_equal command, @writer.command
  end

  def test_options_boolean_arg
    @writer.filenames = %w(a.jpg b.tif c.bmp)
    @writer.values = {:author => 'janfri'}
    @writer.options = {:overwrite_original => true}
    command = 'exiftool -overwrite_original -author=janfri a.jpg b.tif c.bmp'
    assert_equal command, @writer.command
  end

  def test_options_value_arg
    @writer.filenames = %w(a.jpg b.tif c.bmp)
    @writer.values = {:author => 'janfri'}
    @writer.options = {:out => 'output_file'}
    command = 'exiftool -out output_file -author=janfri a.jpg b.tif c.bmp'
    assert_equal command, @writer.command
  end

end
