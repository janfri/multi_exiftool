module MultiExiftool

  class Data

    def initialize values
      @values = {}
      values.map {|tag,val| @values[Data.unify_tag(tag)] = val}
    end

    def [](tag)
      @values[Data.unify_tag(tag)]
    end

    def self.unify_tag tag
      tag.gsub(/[-_]/, '').downcase
    end

    private

    def method_missing tag, *args
      @values[Data.unify_tag(tag.to_s)]
    end

  end

end
