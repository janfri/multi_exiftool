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
        values, messages = MultiExiftool.read(%w(a.jpg b.jpg c.jpg))
        assert_equal @abc_authors, values.map {|e| e['Author']}
        assert_equal @abc_fnumbers, values.map {|e| e['FNumber']}
        assert_equal @abc_titles, values.map {|e| e['Title']}
        assert_equal [], messages.errors_and_warnings
      end
    end

    test 'successful reading with one tag' do
      run_in_temp_dir do
        values, messages = MultiExiftool.read(%w(a.jpg b.jpg c.jpg), tags: %w(title))
        assert_equal @abc_titles, values.map {|e| e['Title']}
        assert_equal [nil] * 3, values.map {|e| e['Author']}
        assert_equal [], messages.errors_and_warnings
      end
    end

    test 'successful reading of hierarchical data' do
      run_in_temp_dir do
        values, messages = MultiExiftool.read(%w(a.jpg), group: 0)
        res = values.first
        assert_equal 'a.jpg', res.source_file
        assert_equal 5.6, res.exif.fnumber
        assert_equal [], messages.errors_and_warnings
      end
    end

    test 'successful reading with numerical option' do
      run_in_temp_dir do
        values, messages = MultiExiftool.read(%w[a.jpg b.jpg c.jpg], tags: %w[orientation], numerical: true)
        assert_equal [1, 2, 3], values.map {|e| e.orientation}
        assert_equal [], messages.errors_and_warnings
      end
    end

    test 'options with boolean argument' do
      run_in_temp_dir do
        values, messages = MultiExiftool.read('a.jpg')
        assert_equal 5.6, values.first.aperture
        values, messages = MultiExiftool.read('a.jpg', e: true)
        assert_equal nil, values.first.aperture
        assert_equal [], messages.errors_and_warnings
      end
    end

    test 'successful reading with user defined tags in config file' do
      run_in_temp_dir do
        values, messages = MultiExiftool.read(%w[a.jpg b.jpg c.jpg], tags: %w[mybasename fileextension])
        assert_equal [nil, nil, nil], values.map(&:mybasename)
        assert_equal [nil, nil, nil], values.map(&:file_extension)
        assert_equal [], messages.errors_and_warnings
        values, messages = MultiExiftool.read(%w[a.jpg b.jpg c.jpg], tags: %w[mybasename fileextension], config: 'example.config')
        assert_equal %w[a b c], values.map(&:mybasename)
        assert_equal %w[jpg]*3, values.map(&:file_extension)
        assert_equal [], messages.errors_and_warnings
      end
    end

    def check_numerical_orientation_a_b_c values, messages
      assert_equal [1, 2, 3], values.map {|e| e.orientation}
      assert_equal [], messages.errors_and_warnings
    end

    test 'alternative arguments of the read method' do
      run_in_temp_dir do
        values, messages = MultiExiftool.read(%w[a.jpg b.jpg c.jpg], tags: %w[orientation], numerical: true)
        check_numerical_orientation_a_b_c values, messages
        values, messages = MultiExiftool.read(%w[a.jpg b.jpg c.jpg], %w[orientation], numerical: true)
        check_numerical_orientation_a_b_c values, messages
        values, messages = MultiExiftool.read(%w[a.jpg b.jpg c.jpg], :orientation, numerical: true)
        check_numerical_orientation_a_b_c values, messages
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
        messages = MultiExiftool.write(@filenames, values)
        assert !messages.errors_or_warnings?
        values, _messages = MultiExiftool.read(@filenames)
        assert_equal %w(foo) * 3, values.map {|e| e.comment}
      end
    end

    test 'tags with spaces in values' do
      run_in_temp_dir do
        values = {author: 'Mister X'}
        messages = MultiExiftool.write(@filenames, values)
        assert !messages.errors_or_warnings?
        values, _messages = MultiExiftool.read(@filenames)
        assert_equal ['Mister X'] * 3, values.map {|e| e.author}
      end
    end

    test 'tags with rational value' do
      run_in_temp_dir do
        values ={exposuretime: Rational(1, 125)}
        messages = MultiExiftool.write(@filenames, values)
        assert !messages.errors_or_warnings?
        values, _messages = MultiExiftool.read(@filenames)
        assert_equal [Rational(1, 125)] * 3, values.map {|e| e.exposuretime}
      end
    end

    test 'tags with array-like values' do
      run_in_temp_dir do
        keywords = ['one', 'two', 'and three']
        values = {keywords: keywords}
        messages = MultiExiftool.write('a.jpg', values)
        assert !messages.errors_or_warnings?
        values, _messages = MultiExiftool.read('a.jpg')
        assert_equal keywords, values.first.keywords
      end
    end

    test 'options with boolean argument' do
      run_in_temp_dir do
        values = {comment: 'foo'}
        options = {overwrite_original: true}
        messages = MultiExiftool.write(@filenames, values, **options)
        assert !messages.errors_or_warnings?
        assert_equal [], Dir['*_original']
      end
    end

    test 'numerical flag' do
      run_in_temp_dir do
        values = {orientation: 2}
        messages = MultiExiftool.write(@filenames, values)
        assert_equal ["Warning: Can't convert IFD0:Orientation (matches more than one PrintConv)"], messages.errors_and_warnings
        messages = MultiExiftool.write(@filenames, values, numerical: true)
        assert !messages.errors_or_warnings?
      end
    end

    test 'alternative arguments of the write method' do
      run_in_temp_dir do
        messages = MultiExiftool.write(@filenames, orientation: 2)
        assert_equal ["Warning: Can't convert IFD0:Orientation (matches more than one PrintConv)"], messages.errors_and_warnings
        messages = MultiExiftool.write(@filenames, orientation: 2, numerical: true)
        assert !messages.errors_or_warnings?
      end
    end

  end

  context 'deleting' do

    setup do
      @filenames = %w(a.jpg b.jpg c.jpg)
    end

    test 'delete all values' do
      run_in_temp_dir do
        messages = MultiExiftool.delete_values(@filenames)
        assert_equal [], messages.errors_and_warnings
        values, messages = MultiExiftool.read(@filenames)
        assert_equal [nil, nil, nil], values.map {|e| e['Author']}
        assert_equal [nil, nil, nil], values.map {|e| e['FNumber']}
        assert_equal [nil, nil, nil], values.map {|e| e['Title']}
        assert_equal [], messages.errors_and_warnings
      end
    end

    test 'delete values for some tags' do
      run_in_temp_dir do
        messages = MultiExiftool.delete_values(@filenames, tags: %w(author title))
        assert_equal [], messages.errors_and_warnings
        values, messages = MultiExiftool.read(@filenames)
        assert_equal [nil, nil, nil], values.map {|e| e['Author']}
        assert_equal [5.6, 6.7, 8], values.map {|e| e['FNumber']}
        assert_equal [nil, nil, nil], values.map {|e| e['Title']}
        assert_equal [], messages.errors_and_warnings
      end
    end

    test 'delete values for one tag' do
      run_in_temp_dir do
        messages = MultiExiftool.delete_values(@filenames, tags: :title)
        assert_equal [], messages.errors_and_warnings
        values, messages = MultiExiftool.read(@filenames)
        assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
        assert_equal [5.6, 6.7, 8], values.map {|e| e['FNumber']}
        assert_equal [nil, nil, nil], values.map {|e| e['Title']}
        assert_equal [], messages.errors_and_warnings
      end
    end

    test 'error if tags do not exist' do
      run_in_temp_dir do
        messages = MultiExiftool.delete_values(@filenames, tags: %w[foo bar])
        warn1, warn2 = messages.warnings
        expected1 = /^Warning: Tag 'foo' is not defined$/
        expected2 = /^Warning: Tag 'bar' is not defined$/
        assert_match expected1, warn1
        assert_match expected2, warn2
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
          messages = MultiExiftool.batch do
            filenames.zip multiple_values do |filename, values|
              write filename, values
            end
          end
          assert_equal [], messages.errors_and_warnings
          values, messages = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], messages.errors_and_warnings
          assert_equal 3, Dir['*_original'].size
        end
      end

      test 'options with boolean argument' do
        run_in_temp_dir do
          filenames = @filenames
          multiple_values = @multiple_values
          options = {overwrite_original: true}
          messages = MultiExiftool.batch do
            filenames.zip multiple_values do |filename, values|
              write filename, values, **options
            end
          end
          assert_equal [], messages.errors_and_warnings
          values, messages = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], messages.errors_and_warnings
          assert_equal [], Dir['*_original']
        end
      end

      test 'batch options' do
        run_in_temp_dir do
          filenames = @filenames
          multiple_values = @multiple_values
          messages = MultiExiftool.batch do
            options.overwrite_original = true
            filenames.zip multiple_values do |filename, values|
              write filename, values
            end
          end
          assert_equal [], messages.errors_and_warnings
          values, messages = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], messages.errors_and_warnings
          assert_equal [], Dir['*_original']
        end
      end

    end

    context 'yield' do

      test 'only filenames and values' do
        run_in_temp_dir do
          messages = MultiExiftool.batch do |batch|
            @filenames.zip @multiple_values do |filename, values|
              batch.write filename, values
            end
          end
          assert_equal [], messages.errors_and_warnings
          values, messages = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], messages.errors_and_warnings
          assert_equal 3, Dir['*_original'].size
        end
      end

      test 'options with boolean argument' do
        run_in_temp_dir do
          options = {overwrite_original: true}
          messages = MultiExiftool.batch do |batch|
            @filenames.zip @multiple_values do |filename, values|
              batch.write filename, values, **options
            end
          end
          assert_equal [], messages.errors_and_warnings
          values, messages = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], messages.errors_and_warnings
          assert_equal [], Dir['*_original']
        end
      end

      test 'batch options' do
        run_in_temp_dir do
          filenames = @filenames
          multiple_values = @multiple_values
          messages = MultiExiftool.batch do |batch|
            batch.options.overwrite_original = true
            filenames.zip multiple_values do |filename, values|
              batch.write filename, values
            end
          end
          assert_equal [], messages.errors_and_warnings
          values, messages = MultiExiftool.read(@filenames)
          assert_equal ['Jan Friedrich'] * 3, values.map {|e| e['Author']}
          assert_equal ['Comment for file a.jpg', 'Comment for file b.jpg', 'Comment for file c.jpg'], values.map {|e| e['Comment']}
          assert_equal [], messages.errors_and_warnings
          assert_equal [], Dir['*_original']
        end
      end

    end

  end

end
