require_relative '../operator.rb'

module Grammar
  module Operators
    class Join < ::Grammar::Operator
      def initialize(params)
        @params = params
        @r1_attr, @operator, @r2_attr = params.split(/([=!<>๐]+)/)
        super()
      end

      def apply(r1, r2)
        validate_attribute_names(r1, r2)
        new_rel = resulting_relation(r1, r2)
        r1.rows.each do |r1_row|
          relation2 = if should_have_one_join_attribute?
                        Projection.new(r2.attribute_names.select { |n| n != @r2_attr.to_sym }.join(',')).apply(r2)
                      else
                        r2
                      end
          r2.rows.zip(relation2.rows).each do |original_r2_row, r2_row_to_join|
            if eval("r1_row.public_send(@r1_attr) #{rubified_operator} original_r2_row.public_send(@r2_attr)")
              new_rel.insert(*r1_row.to_a, *r2_row_to_join.to_a)
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
          raise ::Errors::OperatorError.new(to_s, "first relation's attributes do not include #{@r1_attr}")
        end
        unless r2.attribute_names.include?(@r2_attr.to_sym)
          raise ::Errors::OperatorError.new(to_s, "second relation's attributes do not include #{@r2_attr}")
        end
      end

      def resulting_relation(r1, r2)
        new_rel_attributes = {
          **r1.attributes_hash.transform_keys { |k|
              full_key = k.to_s
              if r2.attribute_names.include?(k) && !(k == @r1_attr.to_sym && should_have_one_join_attribute?)
                if r1.name == r2.name
                  full_key.concat('1')
                else
                  full_key.prepend("#{r1.name}.")
                end
              end
              full_key.to_sym
            },
          **r2.attributes_hash.transform_keys { |k|
              next if k == @r2_attr.to_sym && should_have_one_join_attribute?

              full_key = k.to_s
              if r1.attribute_names.include?(k)
                if r1.name == r2.name
                  full_key.concat('2')
                else
                  full_key.prepend("#{r2.name}.")
                end
              end
              full_key.to_sym
            }
        }
        new_rel_attributes.delete(nil) if should_have_one_join_attribute?
        ::Relation.new(**new_rel_attributes)
      end

      def should_have_one_join_attribute?
        @should_have_one_join_attribute ||= @operator == '๐'
      end

      def rubified_operator
        case @operator
        when '=', '๐' then '=='
        when '<>'     then '!='
        else @operator
        end
      end
    end
  end
end
