module Grammar
  module Errors
    class InvalidExpressionError < ::RuntimeError
      def initialize(expression)
        super("Failed to parse an invalid expression:\n\t#{expression}")
      end
    end
  end
end
