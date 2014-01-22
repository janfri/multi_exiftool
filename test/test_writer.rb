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
      @writer.filenames = %w(a.jpg b.tif c.bmp)
    end

    test 'simple case' do
      @writer.values = {:author => 'janfri'}
      command = 'exiftool -author=janfri a.jpg b.tif c.bmp'
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
      command = 'exiftool -author=janfri -comment=some\ comment a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'tags with rational value' do
      @writer.values ={shutterspeed: Rational(1, 125)}
      command = 'exiftool -shutterspeed=1/125 a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'tags with array-like values' do
      @writer.values = {keywords: ['one', 'two', 'and three']}
      command = 'exiftool -keywords=one -keywords=two -keywords=and\ three a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'options with boolean argument' do
      @writer.values = {:author => 'janfri'}
      @writer.options = {:overwrite_original => true}
      command = 'exiftool -overwrite_original -author=janfri a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'options with value argument' do
      @writer.values = {:author => 'janfri'}
      @writer.options = {:out => 'output_file'}
      command = 'exiftool -out output_file -author=janfri a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'numerical flag' do
      @writer.values = {:author => 'janfri'}
      @writer.numerical = true
      command = 'exiftool -n -author=janfri a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

    test 'overwrite_original flag' do
      @writer.values = {author: 'janfri'}
      @writer.overwrite_original = true
      command = 'exiftool -overwrite_original -author=janfri a.jpg b.tif c.bmp'
      assert_equal command, @writer.command
    end

  end

  context 'write method' do

    test 'successful write' do
      use_fixture('exiftool -author=janfri a.jpg b.tif c.bmp')
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      rc = @writer.write
      assert_equal [], @writer.errors
      assert_equal true, rc
    end

    test 'unsuccessful write' do
      use_fixture('exiftool -author=janfri -foo=x a.jpg xxx')
      @writer.filenames = %w(a.jpg xxx)
      @writer.values = {author: 'janfri', foo: 'x'}
      rc = @writer.write
      assert_equal @fixture['stderr'].chomp, @writer.errors.join("\n")
      assert_equal false, rc
    end

  end

end
