# coding: utf-8
require_relative 'helper'

class TestDataGrouping < Test::Unit::TestCase

  def setup
    hash = {'EXIF' => {'FNumber' => 8, 'Author' => 'janfri'}}
    @data = MultiExiftool::Data.new(hash)
  end

  def test_bracket_access
    assert_equal 8, @data['EXIF']['FNumber']
    assert_equal 'janfri', @data['EXIF']['Author']
  end

  def test_method_access
    assert_equal 8, @data.exif.fnumber
    assert_equal 'janfri', @data.exif.author
  end

  def test_mixed_access
    assert_equal 8, @data.exif['FNumber']
    assert_equal 'janfri', @data.exif['Author']
    assert_equal 8, @data['EXIF'].fnumber
    assert_equal 'janfri', @data['EXIF'].author
  end

end
