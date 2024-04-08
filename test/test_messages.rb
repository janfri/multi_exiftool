# encoding: utf-8
# frozen_string_literal: true

require_relative 'helper'

class TestMessages < Test::Unit::TestCase

  test 'no messages' do
    m = MultiExiftool::Messages.new []
    assert_equal [], m.all
    assert_equal [], m.errors
    assert_equal [], m.infos
    assert_equal [], m.warnings
  end

  test 'info message' do
    all = ['    6 image files read']
    m = MultiExiftool::Messages.new all
    assert_equal all, m.all
    assert_equal [], m.errors
    assert_equal all, m.infos
    assert_equal [], m.warnings
    assert_equal [], m.errors_and_warnings
    assert_equal false, m.errors?
    assert_equal true, m.infos?
    assert_equal false, m.warnings?
    assert_equal false, m.errors_or_warnings?
  end

  test 'warning and info' do
    all = <<~END.split(/\n/)
      Warning: Tag 'xxx' is not defined
      Nothing to do.
    END
    m = MultiExiftool::Messages.new all
    assert_equal all, m.all
    assert_equal [], m.errors
    assert_equal all[1, 1], m.infos
    assert_equal all[0, 1], m.warnings
    assert_equal all[0, 1], m.errors_and_warnings
    assert_equal false, m.errors?
    assert_equal true, m.infos?
    assert_equal true, m.warnings?
    assert_equal true, m.errors_or_warnings?
  end

  test 'error and infos' do
    all = <<~END.split(/\n/)
      Error: File not found - non_existing_file
      0 image files updated
      1 files weren't updated due to errors
    END
    m = MultiExiftool::Messages.new all
    assert_equal all, m.all
    assert_equal all[0, 1], m.errors
    assert_equal all[1, 2], m.infos
    assert_equal [], m.warnings
    assert_equal all[0, 1], m.errors_and_warnings
    assert_equal true, m.errors?
    assert_equal true, m.infos?
    assert_equal false, m.warnings?
    assert_equal true, m.errors_or_warnings?
  end

  test 'warnings and errors and infos' do
    all = <<~END.split(/\n/)
      Warning: Tag 'xxx' is not defined
      Warning: Tag 'yyy' is not defined
      Error: File not found - file1
      Error: File not found - file2
          0 image files updated
          2 files weren't updated due to errors
    END
    m = MultiExiftool::Messages.new all
    assert_equal all, m.all
    assert_equal all[2, 2], m.errors
    assert_equal all[4, 2], m.infos
    assert_equal all[0, 2], m.warnings
    assert_equal all[0, 4], m.errors_and_warnings
    assert_equal true, m.errors?
    assert_equal true, m.infos?
    assert_equal true, m.warnings?
    assert_equal true, m.errors_or_warnings?
  end

  test 'deconstruct keys' do
    all = <<~END.split(/\n/)
      Warning: Tag 'xxx' is not defined
      Warning: Tag 'yyy' is not defined
      Error: File not found - file1
      Error: File not found - file2
          0 image files updated
          2 files weren't updated due to errors
    END
    m = MultiExiftool::Messages.new all
    assert_equal({all: all}, m.deconstruct_keys(%i(all)))
    assert_equal({errors: m.errors}, m.deconstruct_keys(%i(errors)))
    assert_equal({errors: m.errors, warnings: m.warnings}, m.deconstruct_keys(%i(errors warnings)))
    assert_equal({errors: m.errors, infos: m.infos, warnings: m.warnings}, m.deconstruct_keys(%i(errors infos warnings)))
    keys = %i(all errors infos warnings errors_and_warnings warnings_and_errors)
    hash = keys.map {|k| [k, m.send(k)]}.to_h
    assert_equal hash, m.deconstruct_keys(keys)
    assert_equal hash, m.deconstruct_keys(nil)
  end

end
