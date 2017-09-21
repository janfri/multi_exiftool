# encoding: utf-8
# frozen_string_literal: true

require_relative 'helper'

class TestReader < Test::Unit::TestCase

  MANDATORY_ARGS = MultiExiftool::Reader.mandatory_args

  setup do
    @reader = MultiExiftool::Reader.new
  end

  context 'tags' do

    test 'tags are initialized as array' do
      assert_equal [], @reader.tags
    end

    test 'tags could be set as single value' do
      @reader.tags = 'fnumber'
      assert_equal ['fnumber'], @reader.tags
    end

  end

  context 'exiftool_args method' do

    test 'simple case' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      exiftool_args = MANDATORY_ARGS + %w(a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @reader.exiftool_args
    end

    test 'no filenames' do
      assert_raises MultiExiftool::Error do
        @reader.exiftool_args
      end
      @reader.filenames = []
      assert_raises MultiExiftool::Error do
        @reader.exiftool_args
      end
    end

    test 'one filename as string' do
      @reader.filenames = 'a.jpg'
      exiftool_args = MANDATORY_ARGS + %w(a.jpg)
      assert_equal exiftool_args, @reader.exiftool_args
    end

    test 'filenames with spaces' do
      @reader.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
      exiftool_args = MANDATORY_ARGS + ['one file with spaces.jpg', 'another file with spaces.tif']
      assert_equal exiftool_args, @reader.exiftool_args
    end

    test 'tags' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      @reader.tags = %w(author fnumber)
      exiftool_args = MANDATORY_ARGS + %w(-author -fnumber a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @reader.exiftool_args
    end

    test 'options with boolean argument' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      @reader.options = {e: true}
      exiftool_args = MANDATORY_ARGS + %w(-e a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @reader.exiftool_args
    end

    test 'options with value argument' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      @reader.options = {lang: 'de'}
      exiftool_args = MANDATORY_ARGS + %w(-lang de a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @reader.exiftool_args
    end

    test 'numerical flag' do
      @reader.filenames = %w(a.jpg b.jpg c.jpg)
      @reader.numerical = true
      exiftool_args = MANDATORY_ARGS + %w(-n a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @reader.exiftool_args
    end

    test 'group flag' do
      @reader.filenames = %w(a.jpg)
      @reader.group = 0
      exiftool_args = MANDATORY_ARGS + %w(-g0 a.jpg)
      assert_equal exiftool_args, @reader.exiftool_args
      @reader.group = 1
      exiftool_args = MANDATORY_ARGS + %w(-g1 a.jpg)
      assert_equal exiftool_args, @reader.exiftool_args
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
        assert_equal [5.6, 6.7, 8], res.map {|e| e['FNumber']}
        assert_equal %w(SourceFile FNumber), res.first.tags
        assert_equal [], @reader.errors
      end
    end

    test 'successful reading with one tag as symbol' do
      run_in_temp_dir do
        @reader.filenames = %w(a.jpg b.jpg c.jpg)
        @reader.tags = :fnumber
        res =  @reader.read
        assert_equal [5.6, 6.7, 8], res.map {|e| e.fnumber}
        assert_equal %w(SourceFile FNumber), res.first.tags
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
