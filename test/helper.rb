# encoding: utf-8
# frozen_string_literal: true

require_relative '../lib/multi_exiftool'
require 'contest'
require 'fileutils'
require 'test/unit'
require 'tmpdir'

module TestHelper

  DATA_FILES = Dir.glob(File.join(File.dirname(__FILE__), 'data/*'))

  def run_in_temp_dir &block
    Dir.mktmpdir do |tmpdir|
      FileUtils.cp_r DATA_FILES, tmpdir
      Dir.chdir tmpdir do
        block.call
      end
    end
  end

  def assert_array_match_any re, arr
    assert arr.any? {|s| s =~ re}, "#{re.inspect} does not match any entry of #{arr.inspect}"
  end

  def assert_array_match_all re, arr
    assert arr.all? {|s| s =~ re}, "#{re.inspect} does not match all entries of #{arr.inspect}"
  end

end

class Test::Unit::TestCase
  include TestHelper
end
