require 'grammar/operator.rb'

module Grammar
  module Operators
    class Limit < ::Grammar::Operator
      def initialize(params)
        @params = params
        @attribute, @operator, @second_operand = params.split(/([=!<>]+)/)
        super(1)
      end

      def apply(r)
        validate_attribute_names(r)
        unless is_second_operand_an_attribute_name?
          validate_second_operand_type(r)
        end
        new_rel = ::Relation.new(**r.attributes_hash)
        r.rows.each do |row|
          if (is_second_operand_an_attribute_name? &&
               eval("row.public_send(@attribute) #{rubified_operator} row.public_send(@second_operand)")) ||
             (!is_second_operand_an_attribute_name? &&
               eval("row.public_send(@attribute) #{rubified_operator} #{@second_operand}"))
            new_rel.insert(*row.to_a)
          end
        end
        new_rel
      end

      def to_s
        "LIMIT(#{@params})"
      end

      private

      def validate_attribute_names(r)
        unless r.attribute_names.include?(@attribute.to_sym)
          raise ArgumentError,
                "Cannot apply #{to_s}: relation's attributes do not include #{@attribute}"
        end
        if is_second_operand_an_attribute_name? && !r.attribute_names.include?(@second_operand.to_sym)
          raise ArgumentError,
                "Cannot apply #{to_s}: relation's attributes do not include #{@second_operand}"
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
        case r.attributes_hash[@attribute.to_sym]
        when :numeric
          unless @second_operand.match?(/^\d+(\.\d+)?$/)
            raise ArgumentError,
                  "Cannot apply #{to_s}: #{@second_operand} cannot be parsed into a number"
          end
        when :string
          unless @second_operand.match?(/^'.*'$/)
            raise ArgumentError,
                  "Cannot apply #{to_s}: #{@second_operand} is not a string"
          end
        when :date
          parsed_date = ::Date.parse(@second_operand) rescue nil
          if parsed_date.nil?
            raise ArgumentError,
                  "Cannot apply #{to_s}: #{@second_operand} cannot be parsed into a date"
          end
          @second_operand = "::Date.parse(#{@second_operand})"
        end
      end

      def is_second_operand_an_attribute_name?
        @is_second_operand_an_attribute_name ||= @second_operand.match?(/^[[:alpha:]][\w\.]*$/)
      end
    end
  end
end
