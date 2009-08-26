# coding: utf-8
require 'date'
module MultiExiftool

  class Data

    def initialize values
      @values = {}
      values.map {|tag,val| @values[Data.unify_tag(tag)] = val}
    end

    def [](tag)
      parse_value(@values[Data.unify_tag(tag)])
    end

    def self.unify_tag tag
      tag.gsub(/[-_]/, '').downcase
    end

    private

    def method_missing tag, *args
      self[Data.unify_tag(tag.to_s)]
    end

    def parse_value val
      return val unless val.kind_of?(String)
      case val
      when /^(\d{4}):(\d\d):(\d\d) (\d\d):(\d\d):(\d\d)([-+]\d\d:\d\d)?$/
        arr = $~.captures[0,6].map {|cap| cap.to_i}
        arr << $7 if $7
        if arr.size == 7
          DateTime.new(*arr).to_time
        else
          Time.local(*arr) #$1, $2, $3, $4, $5, $6)
        end
      else
        val
      end
    end

  end

end
