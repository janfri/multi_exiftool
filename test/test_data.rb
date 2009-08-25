# coding: utf-8
require_relative 'helper'

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

    setup do
      hash = {'TimestampWithoutZone' => '2009:08:25 12:35:42'}
      @data = MultiExiftool::Data.new(hash)
    end

    test 'local Time object' do
      time = Time.local(2009, 8, 25, 12, 35, 42)
      assert_equal time, @data['TimestampWithoutZone']
    end

  end

end
