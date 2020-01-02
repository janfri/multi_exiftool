# encoding: utf-8
# frozen_string_literal: true

require 'date'
require 'set'

module MultiExiftool

  # Representing (tag, value) pairs of metadata.
  # Access via bracket-methods or dynamic method-interpreting via
  # method_missing.
  class Values

    # Regular expression to determine timestamp values
    REGEXP_TIMESTAMP = /^(\d{4}):(\d\d):(\d\d) (\d\d):(\d\d)(?::((?:\d\d)(?:\.\d+)?))?((?:[-+]\d\d:\d\d)|(?:Z))?(?: *DST)?$/

    # Regular expression to determine rational values
    REGEXP_RATIONAL = %r(^(\d+)/(\d+)$)

    @tag_map = {}

    def initialize values
      @values = {}
      values.map do |tag,val|
        unified_tag = Values.unify_tag(tag)
        Values.tag_map[unified_tag] = tag
        val = val.kind_of?(Hash) ? Values.new(val) : val
        @values[unified_tag] = val
      end
    end

    # Gets the (posible converted) value for a tag
    # (tag will be unified, i.e. FNumber, fnumber or f_number
    # can be used for FNumber)
    def [](tag)
      unified_tag = Values.unify_tag(tag)
      convert(unified_tag, @values[unified_tag])
    end

    # Converts values on the basis of unified tag name and value. It is called
    # each time a value is fethed from a Values instance.
    # @return (maybe) converted value
    def convert tag, val
      return val unless val.kind_of?(String)
      case tag
      when 'partofset', 'track'
        return val
      end
      case val
      when REGEXP_TIMESTAMP
        year, month, day, hour, minute = $~.captures[0,5].map {|cap| cap.to_i}
        if month == 0 || day == 0
          return nil
        end
        second = $6.to_f
        zone = $7
        zone = '+00:00' if zone == 'Z'
        Time.new(year, month, day, hour, minute, second, zone)
      when REGEXP_RATIONAL
        return val if $2.to_i == 0
        Rational($1, $2)
      else
        val
      end
    end

    # Checks if a tag is present
    # @param Tag as string or symbol (will be unified)
    def has_tag? tag
      @values.has_key?(Values.unify_tag(tag.to_s))
    end

    # Gets the original tag names of this instance
    def tags
      @values.keys.map {|tag| Values.tag_map[tag]}
    end

    # Generates a hash representation of this instance
    # with original tag names es keys and converted
    # values as values
    def to_h
      @values.inject(Hash.new) do |h, a|
        tag, val = a
        h[Values.tag_map[tag]] = convert(Values.unify_tag(tag), val)
        h
      end
    end

    alias to_hash to_h

    private

    class << self

      attr_reader :tag_map

      def unify_tag tag
      tag.gsub(/[-_]/, '').downcase
      end

    end

    def method_missing tag, *args, &block
      res = self[Values.unify_tag(tag.to_s)]
      if res && block_given?
        if block.arity > 0
          yield res
        else
          res.instance_eval &block
        end
      end
      res
    end

    def respond_to_missing? tag, *args
      has_tag?(tag) || super
    end
  end

end
