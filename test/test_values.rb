# coding: utf-8
require_relative 'helper'
require 'date'

class TestValues < Test::Unit::TestCase

  context 'value access' do

    setup do
      hash = {'FNumber' => 8, 'Author' => 'janfri'}
      @values = MultiExiftool::Values.new(hash)
    end

    test 'original spelling of tag name' do
      assert_equal 8, @values['FNumber']
    end

    test 'variant spellings of tag names' do
      assert_equal 8, @values['fnumber']
      assert_equal 8, @values['f_number']
      assert_equal 8, @values['f-number']
    end

    test 'tag access via methods' do
      assert_equal 8, @values.fnumber
      assert_equal 8, @values.f_number
    end

  end

  context 'parsing of values' do

    context 'timestamps' do

      setup do
        hash = {
          'TimestampWithoutSeconds' => '2009:08:25 12:35',
          'TimestampWithoutZone' => '2009:08:25 12:35:42',
          'TimestampWithPositiveZone' => '2009:08:26 20:22:24+05:00',
          'TimestampWithNegativeZone' => '2009:08:26 20:22:24-07:00'
        }
        @values = MultiExiftool::Values.new(hash)
      end

      test 'local Time object' do
        time = Time.local(2009, 8, 25, 12, 35)
        assert_equal time, @values['TimestampWithoutSeconds']
        time = Time.local(2009, 8, 25, 12, 35, 42)
        assert_equal time, @values['TimestampWithoutZone']
      end

      test 'Time object with given zone' do
        time = Time.new(2009,8,26,20,22,24,'+05:00')
        values_time = @values['TimestampWithPositiveZone']
        assert_equal time, values_time
        assert_equal 5 * 3600, values_time.utc_offset
        time = Time.new(2009,8,26,20,22,24,'-07:00')
        values_time = @values['TimestampWithNegativeZone']
        assert_equal time, values_time
        assert_equal -7 * 3600, values_time.utc_offset
      end

    end

    context 'other values' do

      setup do
        hash = {
          'ShutterSpeed' => '1/200'
        }
        @values = MultiExiftool::Values.new(hash)
      end

      test 'rational values' do
        assert_equal Rational(1, 200), @values['ShutterSpeed']
      end

    end

  end

end
