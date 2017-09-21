# encoding: utf-8
# frozen_string_literal: true

require_relative 'helper'

class TestExiftoolStuff < Test::Unit::TestCase

  test 'setting exiftool_command resets exiftool_version' do
    MultiExiftool.exiftool_version # ensure @exiftool_version is set
    assert_not_nil MultiExiftool.instance_variable_get('@exiftool_version')
    MultiExiftool.exiftool_command = MultiExiftool.exiftool_command
    assert_nil MultiExiftool.instance_variable_get('@exiftool_version')
  end

  test 'attribute exiftool_version is cached' do
    MultiExiftool.instance_variable_set '@exiftool_version', nil
    t_org = time do
      v = MultiExiftool.exiftool_version
      assert_not_nil v
    end
    t_now = time do
      v = MultiExiftool.exiftool_version
      assert_not_nil v
    end
    assert t_now * 100 < t_org
  end

  protected

  def time
    a = Time.now
    yield
    b = Time.now
    b - a
  end

end
