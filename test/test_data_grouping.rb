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

  test 'block access without block parameter' do
    $ok = false
    $block_self = nil
    res = @data.exif do
      $ok = true
      $block_self = self
    end
    assert $ok, "Block for exif wasn't executed."
    assert_equal @data.exif, $block_self
    assert_equal @data.exif, res
    @data.iptc do
      assert false, "This block should not be executed because IPTC isn't aviable."
    end
  end

  test 'block access with block parameter' do
    $ok = false
    $self = self
    $block_param = nil
    res = @data.exif do |e|
      $ok = true
      $self = self
      $block_param = e
    end
    assert $ok, "Block for exif wasn't executed."
    assert_equal @data.exif, $block_param
    assert_equal self, $self
    assert_equal @data.exif, res
    @data.iptc do
      assert false, "This block should not be executed because IPTC isn't aviable."
    end
  end

end
