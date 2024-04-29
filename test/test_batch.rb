# encoding: utf-8
# frozen_string_literal: true

require_relative 'helper'

class TestBatch < Test::Unit::TestCase

  MANDATORY_WRITER_ARGS = MultiExiftool::Writer.mandatory_args

  test 'empty batch' do
    assert_raises MultiExiftool::Error do
      MultiExiftool::Batch.new.execute
    end
  end

  context 'exiftool_args method' do

    setup do
      @filenames = %w(a.jpg b.jpg c.jpg)
      @multiple_values = @filenames.map do |filename|
        {author: 'janfri', comment: "Comment for file #{filename}"}
      end
    end

    test 'only filenames and values' do
      batch = MultiExiftool::Batch.new
      @filenames.zip @multiple_values do |filename, values|
        batch.write filename, values
      end
      exiftool_args = @filenames.zip(@multiple_values).map do |filename, values|
        [MANDATORY_WRITER_ARGS, '-author=janfri', "-comment=Comment for file #{filename}", filename, '-execute']
      end.flatten
      assert_equal exiftool_args, batch.exiftool_args
    end

    test 'filenames, values and options' do
      options = {overwrite_original: true}
      batch = MultiExiftool::Batch.new
      @filenames.zip @multiple_values do |filename, values|
        batch.write filename, values, **options
      end
      exiftool_args = @filenames.zip(@multiple_values).map do |filename, _values|
        [MANDATORY_WRITER_ARGS, '-overwrite_original', '-author=janfri', "-comment=Comment for file #{filename}", filename, '-execute']
      end.flatten
      assert_equal exiftool_args, batch.exiftool_args
    end

    test 'alternative arguments of the write method' do
      options = {overwrite_original: true}
      batch1 = MultiExiftool::Batch.new
      @filenames.zip @multiple_values do |filename, values|
        batch1.write filename, values, **options
      end
      batch2 = MultiExiftool::Batch.new
      @filenames.zip @multiple_values do |filename, values|
        batch2.write filename, values, overwrite_original: true
      end
      assert_equal batch2.exiftool_args, batch1.exiftool_args
      batch3 = MultiExiftool::Batch.new
      @filenames.zip @multiple_values do |filename, values|
        batch3.write filename, author: :janfri, comment: "Comment for file #{filename}", **options
      end
      assert_equal batch3.exiftool_args, batch1.exiftool_args
      batch4 = MultiExiftool::Batch.new
      @filenames.zip @multiple_values do |filename, values|
        batch4.write filename, author: :janfri, comment: "Comment for file #{filename}", overwrite_original: true
      end
      assert_equal batch4.exiftool_args, batch1.exiftool_args
    end

  end

end
