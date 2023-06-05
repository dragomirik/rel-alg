require 'grammar/operator.rb'

module Grammar
  module Operators
    class Join < ::Grammar::Operator
      def initialize(params)
        @params = params
        super()
      end

      def to_s
        "JOIN(#{@params})"
      end
    end
  end
end
