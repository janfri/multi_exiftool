require_relative 'helper'

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

  def test_tags
    @reader.filenames = %w(a.jpg b.tif c.bmp)
    @reader.tags = %w(author fnumber)
    command = 'exiftool -J -author -fnumber a.jpg b.tif c.bmp'
    assert_equal command, @reader.command
  end

  def test_options_boolean_arg
    @reader.filenames = %w(a.jpg b.tif c.bmp)
    @reader.options = {:e => true}
    command = 'exiftool -J -e a.jpg b.tif c.bmp'
    assert_equal command, @reader.command
  end

  def test_options_value_arg
    @reader.filenames = %w(a.jpg b.tif c.bmp)
    @reader.options = {:lang => 'de'}
    command = 'exiftool -J -lang de a.jpg b.tif c.bmp'
    assert_equal command, @reader.command
  end

  def test_numerical
    @reader.filenames = %w(a.jpg b.tif c.bmp)
    @reader.numerical = true
    command = 'exiftool -J -n a.jpg b.tif c.bmp'
    assert_equal command, @reader.command
  end

  def test_run_nonexisting_file
    mocking_open3('exiftool -J non_existing_file', '', 'File non_existing_file not found.')
    @reader.filenames = %w(non_existing_file)
    res = @reader.read
    assert_equal [], res
    assert_equal ['File non_existing_file not found.'], @reader.errors
  end

  def test_run_with_one_tag
    json = <<-EOS
      [{
        "SourceFile": "a.jpg",
        "FNumber": 11.0
      },
      {
        "SourceFile": "b.tif",
        "FNumber": 9.0
      },
      {
        "SourceFile": "c.bmp",
        "FNumber": 8.0
      }]
    EOS
    json.gsub!(/^ {12}/, '')
    mocking_open3('exiftool -J -fnumber a.jpg b.tif c.bmp', json, '')
    @reader.filenames = %w(a.jpg b.tif c.bmp)
    @reader.tags = %w(fnumber)
    res =  @reader.read
    assert_kind_of Array, res
    assert_equal [11.0, 9.0, 8.0], res.map {|e| e['FNumber']}
    assert_equal [], @reader.errors
  end


end
