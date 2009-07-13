module MultiExiftool

  class Data

    def initialize values
      @values = values
    end

    def [](tag)
      @values[tag]
    end

  end

end
