# coding: utf-8
require_relative 'helper'

class TestWriter < Test::Unit::TestCase

  MANDATORY_ARGS = MultiExiftool::Writer.mandatory_args

  setup do
    @writer = MultiExiftool::Writer.new
  end

  context 'various filename combinations' do

    test 'exiftool_args method, no filenames set' do
      @writer.values = {comment: 'foo'}
      assert_raises MultiExiftool::Error do
        @writer.exiftool_args
      end
      @writer.filenames = []
      assert_raises MultiExiftool::Error do
        @writer.exiftool_args
      end
    end

    test 'one filename as string' do
      @writer.values = {comment: 'foo'}
      @writer.filenames = 'a.jpg'
      exiftool_args = MANDATORY_ARGS + %w(-comment=foo a.jpg)
      assert_equal exiftool_args, @writer.exiftool_args
    end

    test 'filenames with spaces' do
      @writer.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
      @writer.values = {comment: 'foo'}
      exiftool_args = MANDATORY_ARGS + ['-comment=foo', 'one file with spaces.jpg',
                                       'another file with spaces.tif']
      assert_equal exiftool_args, @writer.exiftool_args
    end

  end

  context 'exiftool_args method, various tags' do

    setup do
      @writer.filenames = %w(a.jpg b.jpg c.jpg)
    end

    test 'simple case' do
      @writer.values = {comment: 'foo'}
      exiftool_args = MANDATORY_ARGS + %w(-comment=foo a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @writer.exiftool_args
    end

    test 'no values set' do
      assert_raises MultiExiftool::Error do
        @writer.exiftool_args
      end
      @writer.values = {}
      assert_raises MultiExiftool::Error do
        @writer.exiftool_args
      end
    end

    test 'tags with spaces in values' do
      @writer.values = {title: 'title', :comment => 'some comment'}
      exiftool_args = MANDATORY_ARGS + ['-title=title', '-comment=some comment', 'a.jpg', 'b.jpg', 'c.jpg']
      assert_equal exiftool_args, @writer.exiftool_args
    end

    test 'tags with rational value' do
      @writer.values ={shutterspeed: Rational(1, 125)}
      exiftool_args = MANDATORY_ARGS + %w(-shutterspeed=1/125 a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @writer.exiftool_args
    end

    test 'tags with array-like values' do
      @writer.values = {keywords: ['one', 'two', 'and three']}
      exiftool_args = MANDATORY_ARGS + ['-keywords=one', '-keywords=two', '-keywords=and three',
                                        'a.jpg', 'b.jpg', 'c.jpg']
      assert_equal exiftool_args, @writer.exiftool_args
    end

    test 'options with boolean argument' do
      @writer.values = {comment: 'foo'}
      @writer.options = {:overwrite_original => true}
      exiftool_args = MANDATORY_ARGS + %w(-overwrite_original -comment=foo a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @writer.exiftool_args
    end

    test 'numerical flag' do
      @writer.values = {comment: 'foo'}
      @writer.numerical = true
      exiftool_args = MANDATORY_ARGS + %w(-n -comment=foo a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @writer.exiftool_args
    end

    test 'overwrite_original flag' do
      @writer.values = {comment: 'foo'}
      @writer.overwrite_original = true
      exiftool_args = MANDATORY_ARGS + %w(-overwrite_original -comment=foo a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @writer.exiftool_args
    end

  end

  context 'write method' do

    test 'successful write' do
      run_in_temp_dir do
        @writer.filenames = %w(a.jpg b.jpg c.jpg)
        @writer.values = {comment: 'foo'}
        rc = @writer.write
        assert rc
        assert_equal [], @writer.errors
      end
    end

    test 'unsuccessful write' do
      run_in_temp_dir do
        @writer.filenames = %w(a.jpg xxx)
        @writer.values = {comment: 'foo', bar: 'x'}
        rc = @writer.write
        assert !rc
        assert_equal ["Warning: Tag 'bar' does not exist", "Error: File not found - xxx"], @writer.errors
      end
    end

  end

end
