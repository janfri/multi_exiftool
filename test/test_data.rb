# coding: utf-8
require_relative 'helper'
require 'date'

class TestData < Test::Unit::TestCase

  context 'value access' do

    setup do
      hash = {'FNumber' => 8, 'Author' => 'janfri'}
      @data = MultiExiftool::Data.new(hash)
    end

    test 'original spelling of tag name' do
      assert_equal 8, @data['FNumber']
    end

    test 'variant spellings of tag names' do
      assert_equal 8, @data['fnumber']
      assert_equal 8, @data['f_number']
      assert_equal 8, @data['f-number']
    end

    test 'tag access via methods' do
      assert_equal 8, @data.fnumber
      assert_equal 8, @data.f_number
    end

  end

  context 'parsing of values' do

    context 'timestamps' do

      setup do
        hash = {
          'TimestampWithoutZone' => '2009:08:25 12:35:42',
          'TimestampWithPositiveZone' => '2009:08:26 20:22:24+05:00',
          'TimestampWithNegativeZone' => '2009:08:26 20:22:24-07:00'
        }
        @data = MultiExiftool::Data.new(hash)
      end

      test 'local Time object' do
        time = Time.local(2009, 8, 25, 12, 35, 42)
        assert_equal time, @data['TimestampWithoutZone']
      end

      test 'Time object with given zone' do
        time = DateTime.new(2009,8,26,20,22,24,'+0500').to_time
        assert_equal time, @data['TimestampWithPositiveZone']
        time = DateTime.new(2009,8,26,20,22,24,'-0700').to_time
        assert_equal time, @data['TimestampWithNegativeZone']
      end

    end

    context 'other values' do

      setup do
        hash = {
          'ShutterSpeed' => '1/200'
        }
        @data = MultiExiftool::Data.new(hash)
      end

      test 'rational values' do
        assert_equal Rational(1, 200), @data['ShutterSpeed']
      end

    end

  end

end
