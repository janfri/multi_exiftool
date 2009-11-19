require 'multi_exiftool'

if ARGV.empty?
  $stderr.puts 'No filenames given.'
  exit -1
end

reader = MultiExiftool::Reader.new
reader.filenames = ARGV
reader.group = 0
results = reader.read
results.each do |res|
  # direct access
  puts res.file.filename
  # access via block without parameter
  res.iptc do
    self.keywords do
      puts "  Keywords (IPCT): #{Array(self).join(', ')}"
    end
  end
  # access via block with parameter
  res.xmp do |xmp|
    xmp.keywords do |kw|
      puts "  Keywords (XMP): #{Array(kw).join(', ')}"
    end
  end
end

