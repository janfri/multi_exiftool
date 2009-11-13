# coding: utf-8
require_relative 'helper'

class TestDataGrouping < Test::Unit::TestCase

  setup do
    hash = {'EXIF' => {'FNumber' => 8, 'Author' => 'janfri'}}
    @data = MultiExiftool::Data.new(hash)
  end

  test 'bracket access' do
    assert_equal 8, @data['EXIF']['FNumber']
    assert_equal 'janfri', @data['EXIF']['Author']
  end

  test 'method access' do
    assert_equal 8, @data.exif.fnumber
    assert_equal 'janfri', @data.exif.author
  end

  test 'mixed access' do
    assert_equal 8, @data.exif['FNumber']
    assert_equal 'janfri', @data.exif['Author']
    assert_equal 8, @data['EXIF'].fnumber
    assert_equal 'janfri', @data['EXIF'].author
  end

end
