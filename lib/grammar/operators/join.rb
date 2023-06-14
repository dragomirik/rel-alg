require 'grammar/operator.rb'

module Grammar
  module Operators
    class Join < ::Grammar::Operator
      def initialize(params)
        @params = params
        @r1_attr, @operator, @r2_attr = params.split(/([=!<>]+)/)
        super()
      end

      def apply(r1, r2)
        validate_attribute_names(r1, r2)
        new_rel_attributes = {
          **r1.attributes_hash.transform_keys { |k| r2.attribute_names.include?(k) ? "#{r1.name}.#{k}".to_sym : k },
          **r2.attributes_hash.transform_keys { |k| r1.attribute_names.include?(k) ? "#{r2.name}.#{k}".to_sym : k }
        }
        new_rel = ::Relation.new(**new_rel_attributes)
        r1.rows.each do |r1_row|
          r2.rows.each do |r2_row|
            if eval("r1_row.public_send(@r1_attr) #{rubified_operator} r2_row.public_send(@r2_attr)")
              new_rel.insert(*r1_row.to_a, *r2_row.to_a)
            end
          end
        end
        new_rel
      end

      def to_s
        "JOIN(#{@params})"
      end

      private

      def validate_attribute_names(r1, r2)
        unless r1.attribute_names.include?(@r1_attr.to_sym)
          raise ArgumentError,
                "Cannot apply #{to_s}: first relation's attributes do not include #{@r1_attr}"
        end
        unless r2.attribute_names.include?(@r2_attr.to_sym)
          raise ArgumentError,
                "Cannot apply #{to_s}: second relation's attributes do not include #{@r2_attr}"
        end
      end

      def rubified_operator
        case @operator
        when '='  then '=='
        when '<>' then '!='
        else @operator
        end
      end
    end
  end
end
