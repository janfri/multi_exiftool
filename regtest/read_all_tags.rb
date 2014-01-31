require 'regtest'
require 'multi_exiftool'

include Regtest

sample 'read all tags' do
  MultiExiftool.read('regtest/test.jpg', tags: %w(-exiftoolversion -filemodifydate -fileaccessdate -fileinodechangedate))
end
