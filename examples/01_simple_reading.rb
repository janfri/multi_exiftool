require_relative '../lib/multi_exiftool'

reader = MultiExiftool::Reader.new
reader.filenames = Dir[File.dirname(__FILE__) + '/*.png']
data_objects = reader.read
data_objects.each do |o|
 puts "#{o.file_name}: #{o.comment}"
end
