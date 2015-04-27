require 'rim/tire'
require 'rim/aspell'
require 'rim/version'
require 'regtest/task'

Rim.setup do |p|
  p.name = 'multi_exiftool'
  p.version = '0.4.0'
  p.authors = 'Jan Friedrich'
  p.email = 'janfri26@gmail.com'
  p.summary = 'This library is a wrapper for the Exiftool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool).'
  p.description = 'This library a is wrapper for the Exiftool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool) written by Phil Harvey. It is designed for dealing with multiple files at once by creating commands to call exiftool with various arguments, call it and parsing the results.'
  p.ruby_version = '>=1.9.1'
  p.license = 'MIT'
  p.homepage = 'http://gitorious.org/multi_exiftool'
  p.install_message = %q{
+-----------------------------------------------------------------------+
| Please ensure you have installed exiftool version 7.65 or higher and  |
| it's found in your PATH (Try "exiftool -ver" on your commandline).    |
| For more details see                                                  |
| http://www.sno.phy.queensu.ca/~phil/exiftool/install.html             |
+-----------------------------------------------------------------------+
  }
  p.development_dependencies << 'contest' << 'regtest'
  p.requirements << 'exiftool, version 7.65 or higher'
end
