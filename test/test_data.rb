require_relative '../lib/multi_exiftool'
require 'test/unit'

class TestData < Test::Unit::TestCase

  def test_simple
    hash = {'FNumber' => 8}
    data = MultiExiftool::Data.new(hash)
    assert_equal 8, data['FNumber']
  end

end
