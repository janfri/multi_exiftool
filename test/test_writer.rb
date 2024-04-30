# encoding: utf-8
# frozen_string_literal: true

require_relative 'helper'
require 'yaml'

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
      @writer.values = {title: 'title', comment: 'some comment'}
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
      @writer.options = {overwrite_original: true}
      exiftool_args = MANDATORY_ARGS + %w(-overwrite_original -comment=foo a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @writer.exiftool_args
    end

    test 'numerical flag' do
      @writer.values = {comment: 'foo'}
      @writer.options.numerical = true
      exiftool_args = MANDATORY_ARGS + %w(-n -comment=foo a.jpg b.jpg c.jpg)
      assert_equal exiftool_args, @writer.exiftool_args
    end

    test 'overwrite_original flag' do
      @writer.values = {comment: 'foo'}
      @writer.options.overwrite_original = true
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
        assert_equal [], @writer.messages.errors_and_warnings
        infos = @writer.messages.infos
        assert_equal 1, infos.size
        assert_array_match_any /^\s*3 .+files updated$/, infos
      end
    end

    test 'unsuccessful write' do
      run_in_temp_dir do
        @writer.filenames = %w(a.jpg xxx)
        @writer.values = {comment: 'foo', bar: 'x'}
        rc = @writer.write
        assert !rc
        assert_equal ["Warning: Tag 'bar' is not defined", "Error: File not found - xxx"], @writer.messages.errors_and_warnings
        infos = @writer.messages.infos
        assert_equal 2, infos.size
        assert_array_match_any /^\s*1 .+files updated/, infos
        assert_array_match_any /^\s*1 files weren't updated due to errors$/, infos
      end
    end

  end

  context 'using groups' do

    setup do
      @writer.filenames = %w(a.jpg b.jpg c.jpg)
    end

    test 'simple case' do
      @writer.values = {exif: {comment: 'test'}  }
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

  context 'alternative arguments of the initialize method' do

    setup do
      @filenames = %w(a.jpg b.jpg)
      @values = {iso: 800, fnumber: 5.6}
      @options = {numerical: true, overwrite_original: true}
      @args_without_opts = MANDATORY_ARGS + %w(-iso=800 -fnumber=5.6) + @filenames
      @args_with_opts = MANDATORY_ARGS + %w(-n -overwrite_original -iso=800 -fnumber=5.6) + @filenames
    end

    test 'classical' do
      writer = MultiExiftool::Writer.new(@filenames, @values)
      assert_equal @args_without_opts, writer.exiftool_args
      writer = MultiExiftool::Writer.new(@filenames, @values, **(@options))
      assert_equal @args_with_opts, writer.exiftool_args
    end

    test 'options as explicit arguments' do
      writer = MultiExiftool::Writer.new(@filenames, @values, numerical: true, overwrite_original: true)
      assert_equal @args_with_opts, writer.exiftool_args
    end

    test 'values as explicit arguments no options' do
      writer = MultiExiftool::Writer.new(@filenames, iso: 800, fnumber: 5.6)
      assert_equal @args_without_opts, writer.exiftool_args
    end

    test 'values and options as explicit arguments' do
      writer = MultiExiftool::Writer.new(@filenames, iso: 800, fnumber: 5.6, numerical: true, overwrite_original: true)
      assert_equal @args_with_opts, writer.exiftool_args
      writer = MultiExiftool::Writer.new(@filenames, iso: 800, numerical: true, fnumber: 5.6, overwrite_original: true)
      assert_equal @args_with_opts, writer.exiftool_args
    end

  end

end
