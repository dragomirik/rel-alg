require 'grammar/operator.rb'

module Grammar
  module Operators
    class Division < ::Grammar::Operator
      def initialize(params)
        @params = params
        super()
      end

      def to_s
        "DIVISION(#{@params})"
      end
    end
  end
end
