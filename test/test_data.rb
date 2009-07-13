require_relative '../lib/multi_exiftool'
require 'test/unit'

class TestData < Test::Unit::TestCase

  def setup
    hash = {'FNumber' => 8, 'Author' => 'janfri'}
    @data = MultiExiftool::Data.new(hash)
  end

  def test_simple
    assert_equal 8, @data['FNumber']
  end

  def test_variant_spellings
    assert_equal 8, @data['fnumber']
    assert_equal 8, @data['f_number']
    assert_equal 8, @data['f-number']
  end

end
