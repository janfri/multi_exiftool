# encoding: utf-8
# frozen_string_literal: true

require_relative 'helper'

class TestFunctionalApi < Test::Unit::TestCase

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

    test 'successful reading of hierarchical data' do
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

  context 'deleting' do

    setup do
      @filenames = %w(a.jpg b.jpg c.jpg)
    end

    test 'delete all values' do
      run_in_temp_dir do
        errors = MultiExiftool.delete_values(@filenames)
        assert_equal [], errors
        values, errors = MultiExiftool.read(@filenames)
        assert_equal [nil, nil, nil], values.map {|e| e['Author']}
        assert_equal [nil, nil, nil], values.map {|e| e['FNumber']}
        assert_equal [nil, nil, nil], values.map {|e| e['Title']}
        assert_equal [], errors
      end
    end

    test 'delete values for some tags' do
      run_in_temp_dir do
        errors = MultiExiftool.delete_values(@filenames, tags: %w(author title))
        assert_equal [], errors
        values, errors = MultiExiftool.read(@filenames)
        assert_equal [nil, nil, nil], values.map {|e| e['Author']}
        assert_equal [5.6, 6.7, 8], values.map {|e| e['FNumber']}
        assert_equal [nil, nil, nil], values.map {|e| e['Title']}
        assert_equal [], errors
      end
    end

    test 'delete values for one tag' do
      run_in_temp_dir do
        errors = MultiExiftool.delete_values(@filenames, tags: :title)
        assert_equal [], errors
        values, errors = MultiExiftool.read(@filenames)
        assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
        assert_equal [5.6, 6.7, 8], values.map {|e| e['FNumber']}
        assert_equal [nil, nil, nil], values.map {|e| e['Title']}
        assert_equal [], errors
      end
    end

    test 'error if tags do not exist' do
      run_in_temp_dir do
        errors = MultiExiftool.delete_values(@filenames, tags: %w[foo bar])
        err1, err2, err3 = errors
        expected1 = /^Warning: Tag 'foo' is not (defined|supported)$/
        expected2 = /^Warning: Tag 'bar' is not (defined|supported)$/
        expected3 = 'Nothing to do.'
        assert_match expected1, err1
        assert_match expected2, err2
        assert_equal expected3, err3
      end
    end

  end

  context 'batch' do

    setup do
      @filenames = %w(a.jpg b.jpg c.jpg)
      @multiple_values = @filenames.map do |fn|
        {author: 'Jan Friedrich', comment: "Comment for file #{fn}"}
      end
    end

    context 'instance_exec' do

      test 'only filenames and values' do
        run_in_temp_dir do
          filenames = @filenames
          multiple_values = @multiple_values
          errors = MultiExiftool.batch do
            filenames.zip multiple_values do |filename, values|
              write filename, values
            end
          end
          assert_equal [], errors
          values, errors = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], errors
          assert_equal 3, Dir['*_original'].size
        end
      end

      test 'options with boolean argument' do
        run_in_temp_dir do
          filenames = @filenames
          multiple_values = @multiple_values
          options = {overwrite_original: true}
          errors = MultiExiftool.batch do
            filenames.zip multiple_values do |filename, values|
              write filename, values, options
            end
          end
          assert_equal [], errors
          values, errors = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], errors
          assert_equal [], Dir['*_original']
        end
      end

    end

    context 'yield' do

      test 'only filenames and values' do
        run_in_temp_dir do
          errors = MultiExiftool.batch do |batch|
            @filenames.zip @multiple_values do |filename, values|
              batch.write filename, values
            end
          end
          assert_equal [], errors
          values, errors = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], errors
          assert_equal 3, Dir['*_original'].size
        end
      end

      test 'options with boolean argument' do
        run_in_temp_dir do
          options = {overwrite_original: true}
          errors = MultiExiftool.batch do |batch|
            @filenames.zip @multiple_values do |filename, values|
              batch.write filename, values, options
            end
          end
          assert_equal [], errors
          values, errors = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], errors
          assert_equal [], Dir['*_original']
        end
      end

    end

  end

end
