# coding: utf-8
require_relative 'helper'

class TestWriter < Test::Unit::TestCase

  setup do
    @writer = MultiExiftool::Writer.new
  end

  context 'command method' do

    test 'simple case' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      command = 'exiftool -author=janfri a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'no filenames set' do
      @writer.values = {:author => 'janfri'}
      assert_raises MultiExiftool::Error do
        @writer.command
      end
    end

    test 'no values set' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      assert_raises MultiExiftool::Error do
        @writer.command
      end
    end

    test 'tags with spaces in values' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri', :comment => 'some comment'}
      command = 'exiftool -author=janfri -comment=some\ comment a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'filenames with spaces' do
      @writer.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
      @writer.values = {:author => 'janfri'}
      command = 'exiftool -author=janfri one\ file\ with\ spaces.jpg another\ file\ with\ spaces.tif'
      assert_equal command, @writer.command
    end

    test 'options with boolean argument' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      @writer.options = {:overwrite_original => true}
      command = 'exiftool -overwrite_original -author=janfri a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'options with value argument' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      @writer.options = {:out => 'output_file'}
      command = 'exiftool -out output_file -author=janfri a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'numerical flag' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      @writer.numerical = true
      command = 'exiftool -n -author=janfri a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'overwrite_original flag' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {author: 'janfri'}
      @writer.overwrite_original = true
      command = 'exiftool -overwrite_original -author=janfri a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

  end

  context 'write method' do

    test 'succsessfull write' do
      mocking_open3('exiftool -author=janfri a.jpg b.tif c.bmp', '', '')
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      rc = @writer.write
      assert_equal [], @writer.errors
      assert_equal true, rc
    end

  end

end
