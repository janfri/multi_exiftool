require 'multi_exiftool'
require 'yaml'

if ARGV.empty?
  $stderr.puts 'No filenames given.'
  exit -1
end

puts 'Please enter a description for the given files:'
description = $stdin.gets.chomp

puts 'Please enter a caption for the given files:'
caption = $stdin.gets.chomp

writer = MultiExiftool::Writer.new
writer.filenames = ARGV

# specifying group by prefix
writer.values = {'exif:imagedescription' => description, 'xmp:description' => description}

# specifying group hierarchical
writer.values.merge! YAML.load <<-END
iptc:
  caption-abstract: #{caption}
xmp:
  caption: #{caption}
END

if writer.write
  puts 'ok'
else
  puts writer.messages.warnings_and_errors.join("\n")
end
