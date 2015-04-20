# coding: utf-8
require_relative 'helper'

class TestWriter < Test::Unit::TestCase

  setup do
    @writer = MultiExiftool::Writer.new
  end

  context 'various filename combinations' do

    test 'command method, no filenames set' do
      @writer.values = {:author => 'janfri'}
      assert_raises MultiExiftool::Error do
        @writer.command
      end
      @writer.filenames = []
      assert_raises MultiExiftool::Error do
        @writer.command
      end
    end

    test 'one filename as string' do
      @writer.values = {:author => 'janfri'}
      @writer.filenames = 'a.jpg'
      command = 'exiftool -author=janfri a.jpg'
      assert_equal command, @writer.command
    end

    test 'filenames with spaces' do
      @writer.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
      @writer.values = {:author => 'janfri'}
      command = 'exiftool -author=janfri one\ file\ with\ spaces.jpg another\ file\ with\ spaces.tif'
      assert_equal command, @writer.command
    end

  end

  context 'command method, various tags' do

    setup do
      @writer.filenames = %w(a.jpg b.jpg c.jpg)
    end

    test 'simple case' do
      @writer.values = {:author => 'janfri'}
      command = 'exiftool -author=janfri a.jpg b.jpg c.jpg'
      assert_equal command, @writer.command
    end

    test 'no values set' do
      assert_raises MultiExiftool::Error do
        @writer.command
      end
      @writer.values = {}
      assert_raises MultiExiftool::Error do
        @writer.command
      end
    end

    test 'tags with spaces in values' do
      @writer.values = {:author => 'janfri', :comment => 'some comment'}
      command = 'exiftool -author=janfri -comment=some\ comment a.jpg b.jpg c.jpg'
      assert_equal command, @writer.command
    end

    test 'tags with rational value' do
      @writer.values ={shutterspeed: Rational(1, 125)}
      command = 'exiftool -shutterspeed=1/125 a.jpg b.jpg c.jpg'
      assert_equal command, @writer.command
    end

    test 'tags with array-like values' do
      @writer.values = {keywords: ['one', 'two', 'and three']}
      command = 'exiftool -keywords=one -keywords=two -keywords=and\ three a.jpg b.jpg c.jpg'
      assert_equal command, @writer.command
    end

    test 'options with boolean argument' do
      @writer.values = {:author => 'janfri'}
      @writer.options = {:overwrite_original => true}
      command = 'exiftool -overwrite_original -author=janfri a.jpg b.jpg c.jpg'
      assert_equal command, @writer.command
    end

    test 'options with value argument' do
      @writer.values = {:author => 'janfri'}
      @writer.options = {:out => 'output_file'}
      command = 'exiftool -out output_file -author=janfri a.jpg b.jpg c.jpg'
      assert_equal command, @writer.command
    end

    test 'numerical flag' do
      @writer.values = {:author => 'janfri'}
      @writer.numerical = true
      command = 'exiftool -n -author=janfri a.jpg b.jpg c.jpg'
      assert_equal command, @writer.command
    end

    test 'overwrite_original flag' do
      @writer.values = {author: 'janfri'}
      @writer.overwrite_original = true
      command = 'exiftool -overwrite_original -author=janfri a.jpg b.jpg c.jpg'
      assert_equal command, @writer.command
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
