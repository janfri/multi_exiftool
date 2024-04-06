require 'multi_exiftool'

if ARGV.empty?
  $stderr.puts 'No filenames given.'
  exit -1
end

# Reading only the tags Orientation and Rotation using the -n option of exiftool
results, errors = MultiExiftool.read(ARGV, tags: %w[orientation rotation], numerical: true)

unless errors.empty?
  $stderr.puts reader.errors
  exit 1
end

# Ensuring that for all files with EXIF rotation value of 76 the EXIF value orientation is 6
# end for EXIF rotation value 82 the EXIF orientation value is 8

# Determine the filenames
update_orientation_to_6 = results.select {|r| r.rotation == 76 && r.orientation != 6}.map {|r| r.sourcefile}
update_orientation_to_8 = results.select {|r| r.rotation == 82 && r.orientation != 8}.map {|r| r.sourcefile}

# Update
errors = []
unless update_orientation_to_6.empty?
  errors += MultiExiftool.write(update_orientation_to_6, {orientation: 6}, numerical: true, overwrite_original: true)
end
unless update_orientation_to_8.empty?
  errors += MultiExiftool.write(update_orientation_to_8, {orientation: 8}, numerical: true, overwrite_original: true)
end

unless errors.empty?
  $stderr.puts reader.errors
  exit 1
end
