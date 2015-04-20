# coding: utf-8
require_relative 'helper'
require 'yaml'

class TestWriterGroups < Test::Unit::TestCase

  MANDATORY_ARGS = MultiExiftool::Writer::MANDATORY_ARGS

  setup do
    @writer = MultiExiftool::Writer.new
    @writer.filenames = %w(a.jpg b.jpg c.jpg)
  end

  test 'simple case' do
    @writer.values = {:exif => {:comment => 'test'}  }
    exiftool_args = MANDATORY_ARGS + %w(-exif:comment=test a.jpg b.jpg c.jpg)
    assert_equal exiftool_args, @writer.exiftool_args
  end

  test 'more than one groups and tags' do
    @writer.values = YAML.load <<-END
      exif:
        author: Mr. X
        comment: some comment
      xmp:
        author: Mr. X
        subjectlocation: somewhere else
    END
    exiftool_args = MANDATORY_ARGS + ['-exif:author=Mr. X', '-exif:comment=some comment',
                                      '-xmp:author=Mr. X', '-xmp:subjectlocation=somewhere else',
                                      'a.jpg', 'b.jpg', 'c.jpg']
    assert_equal exiftool_args, @writer.exiftool_args
  end

  test 'tags with array-like values' do
    @writer.values = YAML.load <<-END
      exif:
        keywords:
          - one
          - two
          - and three
    END
    exiftool_args = MANDATORY_ARGS + ['-exif:keywords=one', '-exif:keywords=two', '-exif:keywords=and three',
                                      'a.jpg', 'b.jpg', 'c.jpg']
    assert_equal exiftool_args, @writer.exiftool_args
  end

end
