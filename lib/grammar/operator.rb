module Grammar
  class Operator
    attr_reader :arity

    def initialize(arity = 2)
      @arity = arity
    end

    def apply(*args)
      raise "#{self.class.name}#apply is not implemented"
    end

    def to_s
      self.class.to_s.split('::').last.upcase
    end
  end
end
