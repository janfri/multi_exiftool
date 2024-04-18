# encoding: utf-8
# frozen_string_literal: true

require_relative 'helper'
require 'date'

class TestReaderValues < Test::Unit::TestCase

  context 'value access' do

    setup do
      hash = {'FNumber' => 8, 'Caption-Abstract' => 'some text', 'WB_RGGBLevels' => '84 64 64 86'}
      @values = MultiExiftool::ReaderValues.new(hash)
    end

    test 'original spelling of tag name' do
      assert_equal 8, @values['FNumber']
    end

    test 'variant spellings of tag names' do
      assert_equal 8, @values['fnumber']
      assert_equal 8, @values['FNUMBER']
      assert_nil @values['f_number']
      assert_nil @values['f-number']
    end

    test 'underscores and dashes in tag names are preserved in bracket access' do
      assert_nil @values['f_number']
      assert_nil @values['f-number']
      assert_equal 'some text', @values['Caption-Abstract']
      assert_equal 'some text', @values['caption-abstract']
      assert_equal 'some text', @values['CAPTION-ABSTRACT']
      assert_nil @values['CaptionAbstract']
      assert_nil @values['Caption_Abstract']
      assert_equal '84 64 64 86', @values['WB_RGGBLevels']
      assert_equal '84 64 64 86', @values['wb_rggblevels']
      assert_equal '84 64 64 86', @values['WB_RGGBLEVELS']
      assert_nil @values['WbRGGBLevels']
      assert_nil @values['WB-RGGBLevels']
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
          'Timestamp' => '2009:08:25 12:35:42',
          'TimestampWithFraction' => '2009:08:25 12:35:42.123',
          'TimestampWithPositiveZone' => '2009:08:26 20:22:24+05:00',
          'TimestampWithNegativeZone' => '2009:08:26 20:22:24-07:00',
          'TimestampWithFractionAndZone' => '2016:07:23 15:40:55.123+02:00',
          'TimestampWithZoneAndDST' => '2016:07:23 15:40:55+02:00 DST',
          'TimestampWithZ' => '2017:04:08 17:57:27Z',
          'TimestampWithFractionAndZ' => '2017:04:08 17:57:27.123Z'
        }
        @values = MultiExiftool::ReaderValues.new(hash)
      end

      test 'local Time object' do
        time = Time.local(2009, 8, 25, 12, 35)
        assert_equal time, @values['TimestampWithoutSeconds']
        time = Time.local(2009, 8, 25, 12, 35, 42)
        assert_equal time, @values['Timestamp']
        time = Time.local(2009, 8, 25, 12, 35, 42.123)
        assert_equal time, @values['TimestampWithFraction']
      end

      test 'Time object with given zone' do
        time = Time.new(2009, 8, 26, 20, 22, 24, '+05:00')
        values_time = @values['TimestampWithPositiveZone']
        assert_equal time, values_time
        assert_equal 5 * 3600, values_time.utc_offset
        time = Time.new(2009, 8, 26, 20, 22, 24, '-07:00')
        values_time = @values['TimestampWithNegativeZone']
        assert_equal time, values_time
        assert_equal -7 * 3600, values_time.utc_offset
        time = Time.new(2016, 7, 23, 15, 40, 55.123,'+02:00')
        values_time = @values['TimestampWithFractionAndZone']
        assert_equal time, values_time
      end

      test 'Time object with zone and DST' do
        time = Time.new(2016, 7, 23, 15, 40, 55,'+02:00')
        values_time = @values['TimestampWithZoneAndDST']
        assert_equal time, values_time
      end

      test 'Time object with UTC zone' do
        time = Time.new(2017, 4, 8, 17, 57, 27, '+00:00')
        values_time = @values['TimestampWithZ']
        assert_equal time, values_time
        assert_equal 0, values_time.utc_offset
        time = Time.new(2017, 4, 8, 17, 57, 27.123, '+00:00')
        values_time = @values['TimestampWithFractionAndZ']
        assert_equal time, values_time
        assert_equal 0, values_time.utc_offset
      end

    end

    context 'other values' do

      setup do
        hash = {
          'ShutterSpeed' => '1/200',
          'PartOfSet' => '1/2',
          'Track' => '1/5'
        }
        @values = MultiExiftool::ReaderValues.new(hash)
      end

      test 'rational values' do
        assert_equal Rational(1, 200), @values['ShutterSpeed']
      end

      test 'no rational conversion' do
        assert_equal '1/2', @values['PartOfSet']
        assert_equal '1/5', @values['Track']
      end

    end

    context 'invalid values' do

      test 'timestamp with only zeros' do
        values = MultiExiftool::ReaderValues.new('TimeWithOnlyZeros' => '0000:00:00 00:00:00')
        assert_nil values['TimeWithOnlyZeros']
      end

      test 'timestamp with invalid data' do
        ts =  '2022:25:01 16:25'
        values = MultiExiftool::ReaderValues.new('InvalidTimestamp' => ts)
        assert_equal ts, values['InvalidTimestamp']
      end

      test 'rational with denominator zero' do
        values = MultiExiftool::ReaderValues.new('DenominatorZero' => '1/0')
        assert_equal '1/0', values['DenominatorZero']
      end

    end

  end

  context 'has_tag?' do
    setup do
      @hash = {'FNumber' => 8, 'Author' => 'janfri', 'E-MailAddress' => 'janfri26@gmail.com', 'DateTimeOriginal' => '2018:08:22 11:50:00'}
      @values = MultiExiftool::ReaderValues.new(@hash)
    end

    test 'different formats as string' do
      @hash.keys.each do |k|
        assert_equal true, @values.has_tag?(k)
      end
    end

    test 'different formats as symbol' do
      @hash.keys.each do |k|
        assert_equal true, @values.has_tag?(k.to_sym)
      end
    end

    test 'non existent key' do
      ['iso', 'ISO', :iso, :ISO].each do |t|
        assert_equal false, @values.has_tag?(t)
      end
    end
  end

  context 'tags and to_h' do

    setup do
      @hash = {'FNumber' => 8, 'Author' => 'janfri', 'E-MailAddress' => 'janfri26@gmail.com', 'DateTimeOriginal' => '2017:02:20 21:07:00'}
      @values = MultiExiftool::ReaderValues.new(@hash)
    end

    test 'tags preserves the original tag names' do
      assert_equal @hash.keys, @values.tags.to_a
    end

    test 'to_h preserves original tag names but uses converted values' do
      dto = Time.new(2017, 2, 20, 21, 7, 0)
      @hash['DateTimeOriginal'] = dto
      assert_equal @hash, @values.to_h
    end

  end

  context 'respond_to_missing?' do

    setup do
      hash = {'FNumber' => 8, 'Author' => 'janfri'}
      @values = MultiExiftool::ReaderValues.new(hash)
    end

    test 'existing keys' do
      [:fnumber, :f_number, :FNumber, 'fnumber', 'f_number', 'FNumber', :author, :Author, 'author', 'Author'].each do |t|
        assert_equal true, @values.respond_to?(t)
      end
    end

    test 'non existing key' do
      ['iso', 'ISO', :iso, :ISO].each do |t|
        assert_equal false, @values.respond_to?(t)
      end
    end

  end

  context 'using groups' do

    setup do
      hash = {'EXIF' => {'FNumber' => 8, 'Author' => 'janfri'}}
      @values = MultiExiftool::ReaderValues.new(hash)
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
        assert false, "This block should not be executed because IPTC isn't available."
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
        assert false, "This block should not be executed because IPTC isn't available."
      end
    end

  end


end
