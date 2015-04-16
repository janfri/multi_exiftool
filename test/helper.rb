# coding: utf-8
require_relative '../lib/multi_exiftool'
require 'fileutils'
require 'test/unit'
require 'contest'

module TestHelper

  DATA_DIR = File.join(File.dirname(__FILE__), 'data')
  TEMP_DIR = File.join(File.dirname(__FILE__), 'temp')

  def prepare_temp_dir
    FileUtils.rm_rf TEMP_DIR
    FileUtils.cp_r DATA_DIR, TEMP_DIR
  end

  def run_in_temp_dir &block
    Dir.chdir TEMP_DIR do
      block.call
    end
  end

end

class Test::Unit::TestCase
  include TestHelper
end
