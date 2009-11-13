require 'multi_exiftool'

if ARGV.empty?
  $stderr.puts 'No filenames given.'
  exit -1
end

reader = MultiExiftool::Reader.new
reader.filenames = ARGV
results = reader.read
results.each do |o|
 puts "#{o.file_name}: #{o.comment}"
end
