# coding: utf-8
require_relative 'helper'

class TestFunctionalApi < Test::Unit::TestCase

  context 'reading' do

    test 'successful reading only filenames' do
      use_fixture 'exiftool -J a.jpg b.tif c.bmp'
      values, errors = MultiExiftool.read(%w(a.jpg b.tif c.bmp))
      assert_kind_of Array, values
      assert_equal [11.0, 9.0, 8.0], values.map {|e| e['FNumber']}
      assert_equal [400, 200, 100], values.map {|e| e['ISO']}
      assert_equal [], errors
    end

    test 'successful reading with one tag' do
      use_fixture 'exiftool -J -fnumber a.jpg b.tif c.bmp'
      values, errors = MultiExiftool.read(%w(a.jpg b.tif c.bmp), tags: %w(fnumber))
      assert_kind_of Array, values
      assert_equal [11.0, 9.0, 8.0], values.map {|e| e['FNumber']}
      assert_equal [], errors
    end

    test 'successful reading of hierarichal data' do
      use_fixture 'exiftool -J -g0 -fnumber a.jpg'
      values, errors = MultiExiftool.read(%w(a.jpg), tags: %w[fnumber], group: 0)
      res = values.first
      assert_equal 'a.jpg', res.source_file
      assert_equal 7.1, res.exif.fnumber
      assert_equal 7.0, res.maker_notes.fnumber
      assert_equal [], errors
    end

    test 'generate correct command for numerical option' do
      mocking_open3 'exiftool -J -n -orientation a.jpg', '', ''
      MultiExiftool.read(%w[a.jpg], tags: %w[orientation], numerical: true)
    end

    test 'options with boolean argument' do
      mocking_open3 'exiftool -J -e a.jpg b.tif c.bmp', '', ''
      MultiExiftool.read(%w[a.jpg b.tif c.bmp], e: true)
    end
  end

end
