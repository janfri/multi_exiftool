# encoding: utf-8
# frozen_string_literal: true

module MultiExiftool

  # Representing (tag, value) pairs of metadata to use with Writer#write.
  # Access via bracket-methods or dynamic method-interpreting via
  # method_missing.
  class WriterValues

    def initialize values={}
      @values = {}
      values.each_pair do |k, v|
        self[k] = v
      end
    end

    # Gets the value for a tag (tag will be unified, i.e. FNumber, fnumber or
    # f_number can be used for FNumber)
    def [] tag
      unified_tag = MultiExiftool.unify(tag)
      @values[unified_tag]
    end

    # Sets the value for a tag (tag will be unified, i.e. FNumber, fnumber or
    # f_number can be used for FNumber)
    def []= tag, val
      unified_tag = MultiExiftool.unify(tag)
      if val.respond_to?(:to_hash) && !val.kind_of?(WriterValues)
        val = WriterValues.new(val)
      end
      @values[unified_tag] = val
    end

    def empty?
      @values.empty?
    end

    # Gets a hash representation of this instance
    def to_h
      @values
    end

    alias to_hash to_h

    # :nodoc:

    def values_args
      raise MultiExiftool::Error.new('No values.') if @values.empty?
      values_to_param_array(@values).map {|arg| "-#{arg}"}
    end

    private

    def values_to_param_array hash
      res = []
      hash.each do |tag, val|
        if val.respond_to? :to_hash
          res << values_to_param_array(val.to_hash).map {|arg| "#{tag}:#{arg}"}
        elsif val.respond_to? :to_ary
          res << val.map {|v| "#{tag}=#{v}"}
        else
          res << "#{tag}=#{val}"
        end
      end
      res.flatten
    end

    def method_missing tag, val=nil, &block
      unified_tag = MultiExiftool.unify2(tag)
      if unified_tag =~ /^(.+)=$/
        self[$1] = val
      else
        res = self[unified_tag]
        if block_given?
          res = WriterValues.new unless res
          self[unified_tag] = res
          if block.arity > 0
            yield res
          else
            res.instance_eval &block
          end
        end
        res
      end
    end

  end

end

