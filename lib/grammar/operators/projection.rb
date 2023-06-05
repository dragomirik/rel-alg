require 'grammar/operator.rb'

module Grammar
  module Operators
    class Projection < ::Grammar::Operator
      def initialize(params)
        @params = params
        super(1)
      end

      def to_s
        "PROJECTION(#{@params})"
      end
    end
  end
end
