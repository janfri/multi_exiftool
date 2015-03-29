# coding: utf-8
require_relative 'helper'
require 'fileutils'

class TestActualFiles < Test::Unit::TestCase

  @@dirname = File.join(File.dirname(__FILE__), 'imagefiles')

  def create_tmp_version(name)
    tmp_filename = File.join(@@dirname, 'tmp', name)
    FileUtils.cp(File.join(@@dirname, name), tmp_filename)
    tmp_filename
  end

  setup do
    @writer = MultiExiftool::Writer.new
    @writer.overwrite_original = true
    @writer.filenames = [
      create_tmp_version('screenshot.jpg'),
      create_tmp_version('umlaut äöü.jpg'),
      create_tmp_version('white space file.jpg')
    ]

    @reader = MultiExiftool::Reader.new
    @reader.filenames = @writer.filenames

    @metadata_template = {
      'title' => 'Flawless Screenshot of the Code on GitHub',
#      'copyright' => '©2259 Ämäzing 龍 Unicode LტปέЯ™' # intentionally looking weird.
      'copyright' => 'Hi'
    }
  end

  test 'write then read' do
    @writer.values = @metadata_template
    @writer.write
    assert @writer.errors.empty?, "Writer reported errors: #{@writer.errors}"

    values = @reader.read
    assert @reader.errors.empty?, "Reader reported errors: #{@reader.errors}"
    read_files = 0
    values.each do |metadata|
      read_files += 1
      assert_equal(@metadata_template['imagedescription'], metadata['imagedescription'])
      assert_equal(@metadata_template['copyright'], metadata['copyright'])
    end
    assert_equal @reader.filenames.count, read_files
  end
end
