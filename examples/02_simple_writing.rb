require 'multi_exiftool'

if ARGV.empty?
  $stderr.puts 'No filenames given.'
  exit -1
end

puts 'Please enter a comment for the given files:'
comment = $stdin.gets.chomp

writer = MultiExiftool::Writer.new
writer.filenames = ARGV
writer.options.overwrite_original = true
writer.values = {comment: comment}
if writer.write
  puts 'ok'
else
  puts writer.messages.warnings_and_errors.join("\n")
end
