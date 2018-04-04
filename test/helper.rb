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

end

class Test::Unit::TestCase
  include TestHelper
end
