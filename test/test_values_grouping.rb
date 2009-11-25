# coding: utf-8
require_relative 'helper'

class TestValuesGrouping < Test::Unit::TestCase

  setup do
    hash = {'EXIF' => {'FNumber' => 8, 'Author' => 'janfri'}}
    @values = MultiExiftool::Values.new(hash)
  end

  test 'bracket access' do
    assert_equal 8, @values['EXIF']['FNumber']
    assert_equal 'janfri', @values['EXIF']['Author']
  end

  test 'method access' do
    assert_equal 8, @values.exif.fnumber
    assert_equal 'janfri', @values.exif.author
  end

  test 'mixed access' do
    assert_equal 8, @values.exif['FNumber']
    assert_equal 'janfri', @values.exif['Author']
    assert_equal 8, @values['EXIF'].fnumber
    assert_equal 'janfri', @values['EXIF'].author
  end

  test 'block access without block parameter' do
    $ok = false
    $block_self = nil
    res = @values.exif do
      $ok = true
      $block_self = self
    end
    assert $ok, "Block for exif wasn't executed."
    assert_equal @values.exif, $block_self
    assert_equal @values.exif, res
    @values.iptc do
      assert false, "This block should not be executed because IPTC isn't aviable."
    end
  end

  test 'block access with block parameter' do
    $ok = false
    $self = self
    $block_param = nil
    res = @values.exif do |e|
      $ok = true
      $self = self
      $block_param = e
    end
    assert $ok, "Block for exif wasn't executed."
    assert_equal @values.exif, $block_param
    assert_equal self, $self
    assert_equal @values.exif, res
    @values.iptc do
      assert false, "This block should not be executed because IPTC isn't aviable."
    end
  end

end
