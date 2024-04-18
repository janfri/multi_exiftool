# encoding: utf-8
# frozen_string_literal: true

require_relative 'helper'
require 'date'

class TestWriterValues < Test::Unit::TestCase

  context 'empty init' do

    setup do
      @values = MultiExiftool::WriterValues.new
    end

    test 'default value' do
      assert_nil @values.iso
      assert_nil @values.fnumber
    end

    test 'bracket setter' do
      @values['ISO'] = 400
      @values['Caption-Abstract'] = 'some text'
      assert_equal 400, @values[:iso]
      assert_equal 400, @values.iso
      assert_equal 'some text', @values['caption-abstract']
      assert_equal 'some text', @values['CAPTION-ABSTRACT']
      assert_nil @values.caption_abstract
      assert_nil @values.captionabstract
      assert_equal ['-iso=400', '-caption-abstract=some text'], @values.values_args
    end

    test 'setters' do
      @values.iso = 400
      @values.f_number = 5.6
      assert_equal 400, @values['ISO']
      assert_equal 400, @values.iso
      assert_equal 5.6, @values.fnumber
      assert_equal 5.6, @values.f_number
      assert_equal 5.6, @values[:fnumber]
      assert_nil @values['f-number']
      assert_nil @values['F-Number']
      assert_nil @values['f_number']
      assert_nil @values['F_Number']
      assert_nil @values[:f_number]
      assert_nil @values[:F_Number]
      assert_equal %w(-iso=400 -fnumber=5.6), @values.values_args
    end

    test 'values_args' do
      assert_raises MultiExiftool::Error do
        @values.values_args
      end
      @values.iso = 400
      assert_equal %w(-iso=400), @values.values_args
      @values.f_number = 5.6
      assert_equal %w(-iso=400 -fnumber=5.6), @values.values_args
    end

  end

  context 'value access' do

    setup do
      hash = {'FNumber' => 8, 'Author' => 'janfri'}
      @values = MultiExiftool::WriterValues.new(hash)
    end

    test 'original spelling of tag name' do
      assert_equal 8, @values['FNumber']
      @values['FNumber'] = 5.6
      assert_equal 5.6, @values['FNumber']
    end

    test 'variant spellings of tag names' do
      assert_equal 8, @values['fnumber']
      @values['fnumber'] = 5.6
      assert_equal 5.6, @values['fnumber']
      assert_equal 5.6, @values['FNumber']
      @values['fNumber'] = 8
      assert_equal 8, @values['FNumber']
      assert_equal 8, @values['FNUMBER']
      @values['fNumber'] = 5.6
      assert_equal 5.6, @values['FNUMBER']
    end

    test 'tag access via methods' do
      assert_equal 8, @values.fnumber
      @values.fnumber = 5.6
      assert_equal 5.6, @values.fnumber
      assert_equal 5.6, @values.f_number
      @values.f_number = 8
      assert_equal 8, @values.f_number
    end

    test 'values_args' do
      assert_equal %w(-fnumber=8 -author=janfri), @values.values_args
      @values.iso = 200
      assert_equal %w(-fnumber=8 -author=janfri -iso=200), @values.values_args
      @values.author = nil
      assert_equal %w(-fnumber=8 -author= -iso=200), @values.values_args
    end

  end

  context 'hierarchical access' do

    context 'empty init' do

      setup do
        @values = MultiExiftool::WriterValues.new
      end

      test 'block without arg' do
        c = 'this is a comment'
        @values.exif do
          self.comment = c
        end
        assert_equal c, @values.exif.comment
        assert_equal c, @values['EXIF'].comment
        assert_equal c, @values.exif[:Comment]
        assert_equal c, @values[:exif]['comment']
        assert_equal ['-exif:comment=this is a comment'], @values.values_args
      end

      test 'block arg' do
        c = 'this is a comment'
        @values.exif do |exif|
          exif.comment = c
        end
        assert_equal c, @values.exif.comment
        assert_equal c, @values['exif'].comment
        assert_equal c, @values.exif[:comment]
        assert_equal c, @values[:EXIF]['Comment']
        assert_equal ['-exif:comment=this is a comment'], @values.values_args
      end

    end

    context 'structure init' do

      setup do
        hash = {'EXIF' => {'FNumber' => 8, 'Author' => 'janfri'}}
        @values = MultiExiftool::WriterValues.new(hash)
      end

      test 'block without arg' do
        assert_equal 8, @values.exif.fnumber
        assert_equal 'janfri', @values[:exif]['Author']
        c = 'this is a comment'
        @values.exif do
          self.comment = c
        end
        assert_equal c, @values.exif.comment
        assert_equal ['-exif:fnumber=8', '-exif:author=janfri', '-exif:comment=this is a comment'], @values.values_args
      end

      test 'block arg' do
        assert_equal 8, @values.exif.fnumber
        assert_equal 'janfri', @values[:exif]['Author']
        c = 'this is a comment'
        @values.exif do |exif|
          exif.comment = c
        end
        assert_equal c, @values.exif.comment
        assert_equal ['-exif:fnumber=8', '-exif:author=janfri', '-exif:comment=this is a comment'], @values.values_args
      end

    end

  end

end
