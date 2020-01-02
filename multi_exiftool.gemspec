# -*- encoding: utf-8 -*-
# stub: multi_exiftool 0.12.0 ruby lib
#
# This file is automatically generated by rim.
# PLEASE DO NOT EDIT IT DIRECTLY!
# Change the values in Rim.setup in Rakefile instead.

Gem::Specification.new do |s|
  s.name = "multi_exiftool"
  s.version = "0.12.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jan Friedrich"]
  s.date = "2020-01-02"
  s.description = "This library a is wrapper for the ExifTool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool) written by Phil Harvey. It is designed for dealing with multiple files at once by creating commands to call exiftool with various arguments, call it and parsing the results."
  s.email = "janfri26@gmail.com"
  s.files = ["./.aspell.pws", "Changelog", "Gemfile", "LICENSE", "README.md", "Rakefile", "lib/multi_exiftool", "lib/multi_exiftool.rb", "lib/multi_exiftool/executable.rb", "lib/multi_exiftool/reader.rb", "lib/multi_exiftool/values.rb", "lib/multi_exiftool/writer.rb", "multi_exiftool.gemspec", "regtest/read_all_tags.rb", "regtest/read_all_tags.yml", "regtest/test.jpg", "test/data", "test/data/a.jpg", "test/data/b.jpg", "test/data/c.jpg", "test/helper.rb", "test/test_executable.rb", "test/test_exiftool_stuff.rb", "test/test_functional_api.rb", "test/test_reader.rb", "test/test_values.rb", "test/test_values_using_groups.rb", "test/test_writer.rb", "test/test_writer_groups.rb"]
  s.homepage = "https://github.com/janfri/multi_exiftool"
  s.licenses = ["MIT"]
  s.post_install_message = "\n+-----------------------------------------------------------------------+\n| Please ensure you have installed exiftool version 7.65 or higher and  |\n| it's found in your PATH (Try \"exiftool -ver\" on your commandline).    |\n| For more details see                                                  |\n| http://www.sno.phy.queensu.ca/~phil/exiftool/install.html             |\n+-----------------------------------------------------------------------+\n  "
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.1")
  s.requirements = ["exiftool, version 7.65 or higher"]
  s.rubygems_version = "3.1.2"
  s.summary = "This library is a wrapper for the ExifTool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool)."

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>, [">= 0"])
    s.add_development_dependency(%q<rim>, ["~> 2.17"])
    s.add_development_dependency(%q<contest>, ["~> 0.1"])
    s.add_development_dependency(%q<test-unit>, [">= 0"])
    s.add_development_dependency(%q<regtest>, ["~> 2"])
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rim>, ["~> 2.17"])
    s.add_dependency(%q<contest>, ["~> 0.1"])
    s.add_dependency(%q<test-unit>, [">= 0"])
    s.add_dependency(%q<regtest>, ["~> 2"])
  end
end
