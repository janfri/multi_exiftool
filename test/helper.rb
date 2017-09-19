# coding: utf-8
require_relative '../lib/multi_exiftool'
require 'contest'
require 'fileutils'
require 'test/unit'
require 'tmpdir'

module TestHelper

  DATA_DIR = File.join(File.dirname(__FILE__), 'data')

  def run_in_temp_dir &block
    Dir.tmpdir do |tmpdir|
      FileUtils.cp_r DATA_DIR, tmpdir
      Dir.chdir tmpdir do
        block.call
      end
    end
  end

end

class Test::Unit::TestCase
  include TestHelper
end
