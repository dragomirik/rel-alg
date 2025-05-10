require_relative '../operator.rb'

module Grammar
  module Operators
    class Selection < ::Grammar::Operator
      def initialize(params)
        @params = params
        @attribute, @operator, @second_operand = parse_params(params)
        super(1)
      end

      def apply(r)
        validate_attribute_names(r)
        validate_second_operand_type(r)
        new_rel = ::Relation.new(**r.attributes_hash)
        r.rows.each do |row|
          if eval("row.public_send(@attribute) #{rubified_operator} #{@second_operand}")
            new_rel.insert(*row.to_a)
          end
        end
        new_rel
      end

      def to_s
        "SELECTION(#{@params})"
      end

      private

      def parse_params(params)
        # Split on first occurrence of =, <, >, or <>
        if params.include?('<>')
          attribute, second_operand = params.split('<>', 2)
          [attribute, '<>', second_operand]
        else
          match = params.match(/^([^=<>]+)([=<>])(.+)$/)
          if match
            attribute, operator, second_operand = match.captures
            [attribute.strip, operator, second_operand.strip]
          else
            raise ::Errors::OperatorError.new("LIMIT(#{params})", "invalid operator format")
          end
        end
      end

      def validate_attribute_names(r)
        unless r.attribute_names.include?(@attribute.to_sym)
          raise ::Errors::OperatorError.new(to_s, "relation's attribute '#{@attribute}' not found")
        end
      end

      def rubified_operator
        case @operator
        when '='  then '=='
        when '<>' then '!='
        else @operator
        end
      end

      def validate_second_operand_type(r)
        attr_type = r.attributes_hash[@attribute.to_sym]
        case attr_type
        when :numeric
          if @second_operand.match?(/^\d+(\.\d+)?$/)
            @second_operand = @second_operand # Keep as is
          else
            raise ::Errors::OperatorError.new(to_s, "'#{@second_operand}' cannot be parsed into a number")
          end
        when :string
          # Handle both quoted and unquoted strings
          if @second_operand.match?(/^'.*'$/)
            @second_operand = @second_operand # Keep quoted string as is
          else
            # For unquoted string, take everything up to the next comma or closing bracket
            @second_operand = "'#{@second_operand}'"
          end
        when :date
          parsed_date = ::Date.parse(@second_operand) rescue nil
          if parsed_date.nil?
            raise ::Errors::OperatorError.new(to_s, "'#{@second_operand}' cannot be parsed into a date")
          end
          @second_operand = "::Date.parse('#{@second_operand}')"
        end
      end
    end
  end
end
