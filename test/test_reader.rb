# coding: utf-8
require_relative 'helper'

class TestReader < Test::Unit::TestCase

  setup do
    @reader = MultiExiftool::Reader.new
  end

  context 'command method' do

    test 'simple case' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      command = 'exiftool -J a.jpg b.jpg c.jpg'
      assert_equal command, @reader.command
    end

    test 'no filenames' do
      assert_raises MultiExiftool::Error do
        @reader.command
      end
      @reader.filenames = []
      assert_raises MultiExiftool::Error do
        @reader.command
      end
    end

    test 'one filename as string' do
      @reader.filenames = 'a.jpg'
      command = 'exiftool -J a.jpg'
      assert_equal command, @reader.command
    end

    test 'filenames with spaces' do
      @reader.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
      command = 'exiftool -J one\ file\ with\ spaces.jpg another\ file\ with\ spaces.tif'
      assert_equal command, @reader.command
    end

    test 'tags' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      @reader.tags = %w(author fnumber)
      command = 'exiftool -J -author -fnumber a.jpg b.jpg c.jpg'
      assert_equal command, @reader.command
    end

    test 'options with boolean argument' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      @reader.options = {:e => true}
      command = 'exiftool -J -e a.jpg b.jpg c.jpg'
      assert_equal command, @reader.command
    end

    test 'options with value argument' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      @reader.options = {:lang => 'de'}
      command = 'exiftool -J -lang de a.jpg b.jpg c.jpg'
      assert_equal command, @reader.command
    end

    test 'numerical flag' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      @reader.numerical = true
      command = 'exiftool -J -n a.jpg b.jpg c.jpg'
      assert_equal command, @reader.command
    end

    test 'group flag' do
      @reader.filenames = %w(a.jpg)
      @reader.group = 0
      command = 'exiftool -J -g0 a.jpg'
      assert_equal command, @reader.command
      @reader.group = 1
      command = 'exiftool -J -g1 a.jpg'
      assert_equal command, @reader.command
    end

  end

  context 'read method' do

    test 'try to read a non-existing file' do
      run_in_temp_dir do
        @reader.filenames = %w(non_existing_file)
        res = @reader.read
        assert_equal [], res
        assert_equal ['File not found: non_existing_file'], @reader.errors
      end
    end

    test 'read from an existing and a non-existing file' do
      run_in_temp_dir do
        @reader.filenames = %w(a.jpg xxx)
        @reader.tags = %w(fnumber foo)
        res = @reader.read
        assert_equal [5.6], res.map {|e| e['FNumber']}
        assert_equal ['File not found: xxx'], @reader.errors
      end
    end

    test 'successful reading with one tag' do
      run_in_temp_dir do
        @reader.filenames = %w(a.jpg b.jpg c.jpg)
        @reader.tags = %w(fnumber)
        res =  @reader.read
        assert_kind_of Array, res
        assert_equal [5.6, 6.7, 8], res.map {|e| e['FNumber']}
        assert_equal [], @reader.errors
      end
    end

    test 'successful reading of hierarichal data' do
      run_in_temp_dir do
        @reader.filenames = %w(a.jpg)
        @reader.tags = %w(fnumber)
        @reader.group = 0
        res =  @reader.read.first
        assert_equal 'a.jpg', res.source_file
        assert_equal 5.6, res.exif.fnumber
        assert_equal [], @reader.errors
      end
    end

  end

end
