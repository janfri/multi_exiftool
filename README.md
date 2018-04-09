# MultiExiftool [![Build Status](https://travis-ci.org/janfri/multi_exiftool.svg?branch=master)](https://travis-ci.org/janfri/multi_exiftool)

## Description

This library is a wrapper for the ExifTool command-line application
(http://www.sno.phy.queensu.ca/~phil/exiftool) written by Phil Harvey.
It is designed for dealing with multiple files at once by creating
commands to call exiftool with various arguments, call it and parsing
the results.

## Examples

### Reading

```ruby
require 'multi_exiftool'

# Object oriented approach
reader = MultiExiftool::Reader.new
reader.filenames = Dir['*.jpg']
results = reader.read
unless reader.errors.empty?
  $stderr.puts reader.errors
end
results.each do |values|
  puts "#{values.file_name}: #{values.comment}"
end

# Functional approach
results, errors = MultiExiftool.read(Dir['*.jpg'])
unless reader.errors.empty?
  $stderr.puts reader.errors
end
results.each do |values|
  puts "#{values.file_name}: #{values.comment}"
end
```

### Writing

```ruby
require 'multi_exiftool'

# Object oriented approach
writer = MultiExiftool::Writer.new
writer.filenames = Dir['*.jpg']
writer.values = {creator: 'Jan Friedrich', copyright: 'Public Domain'}
if writer.write
  puts 'ok'
else
  puts writer.errors
end

# Functional approach
errors = MultiExiftool.write(Dir['*.jpg'],  {creator: 'Jan Friedrich', copyright: 'Public Domain'})
if errors.empty?
  puts 'ok'
else
  puts writer.errors
end
```

### Deleting

```ruby
# Delete ALL values
errors = MultiExiftool.delete_values(Dir['*.jpg'])
if errors.empty?
  puts 'ok'
else
  puts writer.errors
end

# Delete values for tags Author and Title
errors = MultiExiftool.delete_values(Dir['*.jpg'], tags: %w(author title))
if errors.empty?
  puts 'ok'
else
  puts writer.errors
end
```

### Further Examples

See the examples in the examples directory.


## Requirements

- Ruby 1.9.1 or higher
- An installation of the ExifTool command-line application (version 7.65 or
higher). Instructions for installation you can find under
http://www.sno.phy.queensu.ca/~phil/exiftool/install.html .
- If you have problems with special characters (like German umlauts) in
filenames on windows system it is recommended to use exiftool version 9.79
or higher.

## Installation

First you need ExifTool (see under Requirements above). Then you can simply
install the gem with
```sh
gem install multi_exiftool
```
or in your Gemfile
```ruby
gem 'multi_exiftool'
```

## Contribution

The code is also hosted in a git repository at
http://github.com/janfri/multi_exiftool
or
https://bitbucket.org/janfri/multi_exiftool
feel free to contribute!

## Author

Jan Friedrich <janfri26gmail.com>

## MIT License

See file LICENSE for details.
