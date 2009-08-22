# coding: utf-8
require_relative 'helper'

class TestData < Test::Unit::TestCase

  setup do
    hash = {'FNumber' => 8, 'Author' => 'janfri'}
    @data = MultiExiftool::Data.new(hash)
  end

  context 'value access' do

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

end
