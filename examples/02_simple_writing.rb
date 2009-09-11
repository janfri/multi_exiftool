require 'multi_exiftool'

writer = MultiExiftool::Writer.new
writer.filenames = Dir[File.dirname(__FILE__) + '/*.png']
writer.overwrite_original = true
writer.values = {author: 'janfri'}
if writer.write
  puts 'ok'
else
  puts writer.errors.join
end
