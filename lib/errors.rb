module Errors
  class RelationalAlgebraError < StandardError
  end

  class OperatorError < RelationalAlgebraError
    def initialize(operator_str, msg)
      super("Cannot apply #{operator_str}: #{msg}")
    end
  end

  class SetOperatorTypeError < OperatorError
    def initialize(operator_str, r1, r2)
      super(
        operator_str,
        "relations' attribute types don't match\n"\
        "#{r1.name || 'Relation 1'}: #{r1.attributes.map(&:type)}\n"\
        "#{r2.name || 'Relation 2'}: #{r2.attributes.map(&:type)}"
      )
    end
  end

  class InterpretationError < RelationalAlgebraError
    def initialize(original_error, line, line_n, data)
      super(
        "Error on line #{line_n}: #{line}\n\n"\
        "#{original_error.message}\n\n#{original_error.backtrace[0, 10].join("\n")}\n\n"\
        "Data at failure time:\n\n#{data.to_s(reverse: true)}"
      )
    end
  end

  class UnknownRelationError < RelationalAlgebraError
    def initialize(relation_name, data)
      super(
        "Unknown relation '#{relation_name}'. "\
        "Known relations include: #{data.to_h.keys.map { |n| "'#{n}'" }.join(', ')}"
      )
    end
  end
end
