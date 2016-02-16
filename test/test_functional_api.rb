# coding: utf-8
require_relative 'helper'

class TestFunctionalApi < Test::Unit::TestCase

  setup do
    prepare_temp_dir
  end

  context 'reading' do

    setup do
      @abc_authors = ['Jan Friedrich'] * 3
      @abc_fnumbers = [5.6, 6.7, 8]
      @abc_titles = 'Title A,Title B,Title C'.split(/,/)
    end

    test 'successful reading only filenames' do
      run_in_temp_dir do
        values, errors = MultiExiftool.read(%w(a.jpg b.jpg c.jpg))
        assert_equal @abc_authors, values.map {|e| e['Author']}
        assert_equal @abc_fnumbers, values.map {|e| e['FNumber']}
        assert_equal @abc_titles, values.map {|e| e['Title']}
        assert_equal [], errors
      end
    end

    test 'successful reading with one tag' do
      run_in_temp_dir do
        values, errors = MultiExiftool.read(%w(a.jpg b.jpg c.jpg), tags: %w(title))
        assert_equal @abc_titles, values.map {|e| e['Title']}
        assert_equal [nil] * 3, values.map {|e| e['Author']}
        assert_equal [], errors
      end
    end

    test 'successful reading of hierarichal data' do
      run_in_temp_dir do
        values, errors = MultiExiftool.read(%w(a.jpg), group: 0)
        res = values.first
        assert_equal 'a.jpg', res.source_file
        assert_equal 5.6, res.exif.fnumber
        assert_equal [], errors
      end
    end

    test 'successful reading with numerical option' do
      run_in_temp_dir do
        values, errors = MultiExiftool.read(%w[a.jpg b.jpg c.jpg], tags: %w[orientation], numerical: true)
        assert_equal [1, 2, 3], values.map {|e| e.orientation}
        assert_equal [], errors
      end
    end

    test 'options with boolean argument' do
      run_in_temp_dir do
        values, errors = MultiExiftool.read('a.jpg')
        assert_equal 5.6, values.first.aperture
        values, errors = MultiExiftool.read('a.jpg', e: true)
        assert_equal nil, values.first.aperture
        assert_equal [], errors
      end
    end

  end

  context 'writing' do

    setup do
      @filenames = %w(a.jpg b.jpg c.jpg)
    end

    test 'simple case' do
      run_in_temp_dir do
        values = {comment: 'foo'}
        errors = MultiExiftool.write(@filenames, values)
        assert errors.empty?
        values, _errors = MultiExiftool.read(@filenames)
        assert_equal %w(foo) * 3, values.map {|e| e.comment}
      end
    end

    test 'tags with spaces in values' do
      run_in_temp_dir do
        values = {author: 'Mister X'}
        errors = MultiExiftool.write(@filenames, values)
        assert errors.empty?
        values, _errors = MultiExiftool.read(@filenames)
        assert_equal ['Mister X'] * 3, values.map {|e| e.author}
      end
    end

    test 'tags with rational value' do
      run_in_temp_dir do
        values ={exposuretime: Rational(1, 125)}
        errors = MultiExiftool.write(@filenames, values)
        assert errors.empty?
        values, _errors = MultiExiftool.read(@filenames)
        assert_equal [Rational(1, 125)] * 3, values.map {|e| e.exposuretime}
      end
    end

    test 'tags with array-like values' do
      run_in_temp_dir do
        keywords = ['one', 'two', 'and three']
        values = {keywords: keywords}
        errors = MultiExiftool.write('a.jpg', values)
        assert errors.empty?
        values, _errors = MultiExiftool.read('a.jpg')
        assert_equal keywords, values.first.keywords
      end
    end

    test 'options with boolean argument' do
      run_in_temp_dir do
        values = {comment: 'foo'}
        options = {overwrite_original: true}
        errors = MultiExiftool.write(@filenames, values, options)
        assert errors.empty?
        assert_equal [], Dir['*_original']
      end
    end

    test 'numerical flag' do
      run_in_temp_dir do
        values = {orientation: 2}
        errors = MultiExiftool.write(@filenames, values)
        assert_equal ["Warning: Can't convert IFD0:Orientation (matches more than one PrintConv)", "Nothing to do."], errors
        errors = MultiExiftool.write(@filenames, values, numerical: true)
        assert errors.empty?
      end
    end

  end

end
