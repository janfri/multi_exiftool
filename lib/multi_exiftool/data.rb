# coding: utf-8
require 'date'
module MultiExiftool

  # Representing (tag, value) pairs of metadata.
  # Access via bracket-methods or dynamic method-interpreting via
  # method_missing.
  class Data

    def initialize values
      @values = {}
      values.map do |tag,val|
        val = val.kind_of?(Hash) ? Data.new(val) : val
        @values[Data.unify_tag(tag)] = val
      end
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
          Time.local(*arr)
        end
      when %r(^(\d+)/(\d+)$)
        Rational($1, $2)
      else
        val
      end
    end

  end

end
