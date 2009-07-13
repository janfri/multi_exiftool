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

  def test_tags
    @reader.filenames = %w(a.jpg b.tif c.bmp)
    @reader.tags = %w(author fnumber)
    command = 'exiftool -J -author -fnumber a.jpg b.tif c.bmp'
    assert_equal command, @reader.command
  end

  def test_run
    # Stubbing execute_command, the Ruby way :)
    class << @reader
      def execute_command
        expected_command = 'exiftool -J -fnumber a.jpg b.tif c.bmp'
        if command == expected_command
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
          @stdout = StringIO.new(json)
          @stderr = StringIO.new('')
        else
          @stdout = StringIO.new('')
          @stderr = StringIO.new(format("Expected: %s\nGot: %s", expected_command, command))
        end
      end
    end
    @reader.filenames = %w(a.jpg b.tif c.bmp)
    res = @reader.read
    assert_equal [], res
    @reader.tags = %w(fnumber)
    res = @reader.read
    assert_kind_of Array, res
    assert_equal 3, res.size
    assert_equal [11.0, 9.0, 8.0], res.map {|e| e['FNumber']}
    assert_equal [], @reader.errors
  end

end
