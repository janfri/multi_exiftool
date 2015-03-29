# coding: utf-8
require_relative 'helper'
require 'yaml'

class TestWriterGroups < Test::Unit::TestCase

  setup do
    @writer = MultiExiftool::Writer.new
    @writer.filenames = %w(a.jpg b.bmp c.tif)
  end

  test 'simple case' do
    @writer.values = {:exif => {:comment => 'test'}  }
    command = ['exiftool', '-exif:comment=test', 'a.jpg', 'b.bmp', 'c.tif']
    assert_equal command, @writer.command
  end

  test 'more than one groups and tags' do
    @writer.values = YAML.load <<-END
      exif:
        author: janfri
        comment: some comment
      xmp:
        author: janfri
        subjectlocation: somewhere else
    END
    command = ['exiftool', '-exif:author=janfri', '-exif:comment=some comment', '-xmp:author=janfri', '-xmp:subjectlocation=somewhere else', 'a.jpg', 'b.bmp', 'c.tif']
    assert_equal command, @writer.command
  end

  test 'tags with array-like values' do
    @writer.values = YAML.load <<-END
      exif:
        keywords:
          - one
          - two
          - and three
    END
    command = ['exiftool', '-exif:keywords=one', '-exif:keywords=two', '-exif:keywords=and three', 'a.jpg', 'b.bmp', 'c.tif']
    assert_equal command, @writer.command
  end

end
