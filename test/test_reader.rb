require_relative 'helper'

class TestReader < Test::Unit::TestCase

  setup do
    @reader = MultiExiftool::Reader.new
  end

  context 'command method' do

    test 'simple case' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      command = 'exiftool -J a.jpg b.tif c.bmp'
      assert_equal command, @reader.command
    end

    test 'no filenames' do
      assert_raises MultiExiftool::Error do
        @reader.command
      end
    end

    test 'filenames with spaces' do
      @reader.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
      command = 'exiftool -J one\ file\ with\ spaces.jpg another\ file\ with\ spaces.tif'
      assert_equal command, @reader.command
    end

    test 'tags' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.tags = %w(author fnumber)
      command = 'exiftool -J -author -fnumber a.jpg b.tif c.bmp'
      assert_equal command, @reader.command
    end

    test 'options with boolean argument' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.options = {:e => true}
      command = 'exiftool -J -e a.jpg b.tif c.bmp'
      assert_equal command, @reader.command
    end

    test 'options with value argument' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.options = {:lang => 'de'}
      command = 'exiftool -J -lang de a.jpg b.tif c.bmp'
      assert_equal command, @reader.command
    end

    test 'numerical flag' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.numerical = true
      command = 'exiftool -J -n a.jpg b.tif c.bmp'
      assert_equal command, @reader.command
    end

  end

  context 'read method' do

    test 'try to read a non-existing file' do
      mocking_open3('exiftool -J non_existing_file', '', 'File non_existing_file not found.')
      @reader.filenames = %w(non_existing_file)
      res = @reader.read
      assert_equal [], res
      assert_equal ['File non_existing_file not found.'], @reader.errors
    end

    test 'successful reading with one tag' do
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
      json.gsub!(/^ {8}/, '')
      mocking_open3('exiftool -J -fnumber a.jpg b.tif c.bmp', json, '')
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.tags = %w(fnumber)
      res =  @reader.read
      assert_kind_of Array, res
      assert_equal [11.0, 9.0, 8.0], res.map {|e| e['FNumber']}
      assert_equal [], @reader.errors
    end

  end

end
