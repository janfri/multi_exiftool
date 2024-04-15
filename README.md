# MultiExiftool ![test workflow](https://github.com/janfri/multi_exiftool/actions/workflows/main.yml/badge.svg)

## Description

This library is a wrapper for the ExifTool command-line application
(https://exiftool.org) written by Phil Harvey.
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
messages = reader.messages
if messages.errors_or_warnings?
  $stderr.puts reader.errors_and_warnings
end
results.each do |values|
  puts "#{values.file_name}: #{values.comment}"
end

# Functional approach
results, messages = MultiExiftool.read(Dir['*.jpg'])
if messages.errors_or_warnings?
  $stderr.puts messages.errors_and_warnings
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
  puts writer.messages.errors_and_warnings
end

# Functional approach
messages = MultiExiftool.write(Dir['*.jpg'],  {creator: 'Jan Friedrich', copyright: 'Public Domain'})
if !messages.warnings_or_errors?
  puts 'ok'
else
  puts messages.warnings_and_errors
end
```

If it is necessary to write different values to multiple files there is batch processing

```ruby
require 'multi_exiftool'

# Object oriented approach

batch = MultiExiftool::Batch.new
Dir['*.jpg'].each_with_index do |filename, i|
  values = {creator: 'Jan Friedrich', copyright: 'Public Domain', comment: "This is file number #{i+1}."}
  batch.write filename, values
end
if batch.execute
  puts 'ok'
else
  puts batch.messages.errors_and_warnings
end

# Functional approach

messages = MultiExiftool.batch do
  Dir['*.jpg'].each_with_index do |filename, i|
    values = {creator: 'Jan Friedrich', copyright: 'Public Domain', comment: "This is file number #{i+1}."}
    write filename, values
  end
end
if !messages.errors_or_warnings?
  puts 'ok'
else
  puts messages.errors_and_warnings
end

# or alternative with block parameter as yielded Batch instance

messages = MultiExiftool.batch do |batch|
  Dir['*.jpg'].each_with_index do |filename, i|
    values = {creator: 'Jan Friedrich', copyright: 'Public Domain', comment: "This is file number #{i+1}."}
    batch.write filename, values
  end
end
if !messages.errors_or_warnings?
  puts 'ok'
else
  puts errors
end
```


### Deleting

```ruby
# Delete ALL values
messages = MultiExiftool.delete_values(Dir['*.jpg'])
if !messages.errors_or_warnings?
  puts 'ok'
else
  puts messages.errors_and_warnings
end

# Delete values for tags Author and Title
messages = MultiExiftool.delete_values(Dir['*.jpg'], tags: %w(author title))
if !messages.warnings_or_errors?
  puts 'ok'
else
  puts messages.errors_and_warnings
end
```

### Further Examples

See the examples in the examples directory.


## Automatic conversion of values

By default values are converted to useful instances of Ruby classes. The
following conversions are implemented at the moment:

* Timestamps => Time (with local time zone of no one given)
* values of form "n/m" => Rational except PartOfSet and Track

The conversion is done in the method ReaderValues#convert. So you can change it's
behaviour as following examples show.

### Example 1

```ruby
module MyConversion
  def convert tag, val
    val # no conversion at all
  end
end

MultiExiftool::ReaderValues.prepend MyConversion
```

### Example 2

```ruby
module MultiExiftool
  module MyConversion
    def convert tag, val
      converted_val = super
      case converted_val
      when Time
        converted_val.utc # convert Time objects to utc
      when Rational
        val # no conversion
      else
        converted_val # use default conversion
      end
    end
  end

  ReaderValues.prepend MyConversion
end
```

### Example 3

```ruby
m = Module.new do
  def convert tag, val
    if val =~ MultiExiftool::ReaderValues::REGEXP_TIMESTAMP
      val # no conversion
    else
      super # use default conversion
    end
  end
end
MultiExiftool::ReaderValues.prepend m
```

The method ReaderValues#convert is called each time a value is fetched.


## Requirements

- Ruby 1.9.1 or higher
- An installation of the ExifTool command-line application (version 11.10 or
higher). Instructions for installation you can find under
https://exiftool.org/install.html .

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

## Versioning

MultiExiftool follows [Semantic Versioning](https://semver.org/), both SemVer and
SemVerTag.

## Author

Jan Friedrich <janfri26@gmail.com>

## MIT License

See file LICENSE for details.
