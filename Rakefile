require 'echoe'

Echoe.new('multi_exiftool') do |p|
  p.author = 'Jan Friedrich'
  p.email = 'janfri.rubyforge@gmail.com'
  p.summary = 'An alternative approach for a ruby interface to the exiftool command-line application for better dealing with mass processing than MiniExiftool.'
  p.ruby_version = '>=1.9.1'
  p.url = 'http://rubyforge.org/projects/multiexiftool'
  p.install_message = %q{
+-----------------------------------------------------------------------+
| Please ensure you have installed exiftool version 7.65 or higher and  |
| it's found in your PATH (Try "exiftool -ver" on your commandline).    |
| For more details see                                                  |
| http://www.sno.phy.queensu.ca/~phil/exiftool/install.html             |
+-----------------------------------------------------------------------+
  }
  p.development_dependencies = ['contest']
  p.eval = proc do
    self.requirements << 'exiftool, version 7.65 or higher'
  end
end
