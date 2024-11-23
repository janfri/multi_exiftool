# encoding: utf-8
require_relative 'lib/multi_exiftool'

Gem::Specification.new do |s|
  s.name = 'multi_exiftool'
  s.version = MultiExiftool::VERSION

  s.author = 'Jan Friedrich'
  s.email = 'janfri26@gmail.com'

  s.summary = 'This library is a wrapper for the ExifTool command-line application (https://exiftool.org).'
  s.description = 'This library is a wrapper for the ExifTool command-line application (https://exiftool.org) written by Phil Harvey. It is designed for dealing with multiple files at once by creating commands to call exiftool with various arguments, call it and parsing the results.'
  s.homepage = 'https://github.com/janfri/multi_exiftool'

  s.license = 'MIT'

  s.require_paths = 'lib'
  s.files = %w[Changelog LICENSE README.md] + Dir['examples/**/*'] + Dir['lib/**/*']

  s.post_install_message = <<~END
    +-----------------------------------------------------------------------+
    | Please ensure you have installed exiftool version 11.10 or higher and |
    | it's found in your PATH (Try "exiftool -ver" on your commandline).    |
    | For more details see                                                  |
    | https://exiftool.org/install.html                                     |
    +-----------------------------------------------------------------------+
  END

  s.required_ruby_version = '>= 2.3'
  s.requirements << 'exiftool, version 11.10 or higher'

  s.add_development_dependency 'contest', '~> 0.1'
  s.add_development_dependency 'fileutils', '>= 1.7.3'
  s.add_development_dependency 'rake', '>= 0'
  s.add_development_dependency 'regtest', '~> 2'
  s.add_development_dependency 'rim', '~> 3.0'
  s.add_development_dependency 'test-unit', '>= 0'
end
