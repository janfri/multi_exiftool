# encoding: utf-8
# frozen_string_literal: true

require_relative 'helper'

class TestOptions < Test::Unit::TestCase

  context 'empty options' do

    setup do
      @options = MultiExiftool::Options.new
    end

    test 'alias access' do
      assert_nil @options.n
      assert_nil @options.numerical
      @options.numerical = true
      assert @options.n
      assert @options.numerical
      assert @options.noprintconv
    end

    test 'case handling' do
      assert_nil @options.Numerical
      assert_nil @options.SORT
      assert_nil @options.P
      assert_raises MultiExiftool::Error do
        @options.N
      end
      assert_raises MultiExiftool::Error do
        @options.p
      end
    end

    test 'underscore handling' do
      assert_nil @options.no_print_conv
      @options.noprintconv = true
      assert @options.no_print_conv
    end

    test 'non members' do
      assert_raises MultiExiftool::Error do
        @options.x
      end
      assert_raises MultiExiftool::Error do
        @options.x = true
      end
      assert_raises MultiExiftool::Error do
        @options.p
      end
      assert_raises MultiExiftool::Error do
        @options.p = true
      end
    end

    test 'to_h' do
      h = {}
      assert_equal h, @options.to_h
      @options.numerical = true
      h = {n: true}
      assert_equal h, @options.to_h
      h = {n: false}
      @options.numerical = false
      assert_equal h, @options.to_h
      h = {}
      @options.numerical = nil
      assert_equal h, @options.to_h
    end

    test 'options_args' do
      assert_equal [], @options.options_args
      @options.noprintconv = true
      assert_equal %w(-n), @options.options_args
      @options.binary = true
      assert_equal %w(-b -n), @options.options_args
      @options.numerical = false
      assert_equal %w(-b), @options.options_args
      @options.numerical = nil
      assert_equal %w(-b), @options.options_args
      @options.b = false
      assert_equal [], @options.options_args
      @options.b = nil
      assert_equal [], @options.options_args
    end

  end

  context 'initialized options' do

    setup do
      @hash = {numerical: true, iptc_charset: :Latin, exif_charset: 'UTF-8', lang: :de}
      @options = MultiExiftool::Options.new(@hash)
    end

    test 'values are initialized' do
      assert @options.n
      assert @options.numerical
      assert @options.noprintconv
      assert_equal :Latin, @options.iptc_charset
      assert_equal 'UTF-8', @options.exif_charset
      assert_equal :de, @options.lang
      assert_nil @options.binary
    end

    test 'options_args' do
      assert_equal %w(-charset exif=UTF-8 -charset iptc=Latin -lang de -n), @options.options_args
      @options.m = true
      assert_equal %w(-charset exif=UTF-8 -charset iptc=Latin -lang de -m -n), @options.options_args
      @options.iptc_charset = nil
      assert_equal %w(-charset exif=UTF-8 -lang de -m -n), @options.options_args
    end

  end

  context 'numerical options' do

    setup do
      @hash = {group: 2, F: 1, fast: 1, ee: 1}
      @options = MultiExiftool::Options.new(@hash)
    end

    test 'options_args' do
      assert_equal %w(-F1 -ee1 -fast1 -g2), @options.options_args
    end

  end

end
