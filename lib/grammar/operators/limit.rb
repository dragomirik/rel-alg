require 'grammar/operator.rb'

module Grammar
  module Operators
    class Limit < ::Grammar::Operator
      def initialize(params)
        @params = params
        super(1)
      end

      def to_s
        "LIMIT(#{@params})"
      end
    end
  end
end
