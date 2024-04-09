require 'multi_exiftool'

if ARGV.empty?
  $stderr.puts 'No filenames given.'
  exit -1
end

# Reading only the tags Orientation and Rotation using the -n option of exiftool
results, messages = MultiExiftool.read(ARGV, tags: %w[orientation rotation], numerical: true)

if messages.errors_or_warnings?
  $stderr.puts reader.messages.warnings_and_errors
  exit 1
end

# Ensuring that for all files with EXIF rotation value of 76 the EXIF value orientation is 6
# and for EXIF rotation value 82 the EXIF orientation value is 8

# Determine the filenames
update_orientation_to_6 = results.select {|r| r.rotation == 76 && r.orientation != 6}.map {|r| r.sourcefile}
update_orientation_to_8 = results.select {|r| r.rotation == 82 && r.orientation != 8}.map {|r| r.sourcefile}

# Update
errors_and_warnings = []
unless update_orientation_to_6.empty?
  messages = MultiExiftool.write(update_orientation_to_6, {orientation: 6}, numerical: true, overwrite_original: true)
  errors_and_warnings += messages.errors_and_warnings
end
unless update_orientation_to_8.empty?
  messages = MultiExiftool.write(update_orientation_to_8, {orientation: 8}, numerical: true, overwrite_original: true)
  errors_and_warnings += messages.errors_and_warnings
end

unless errors_and_warnings.empty?
  $stderr.puts reader.errors
  exit 1
end
