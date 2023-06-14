require 'grammar/operator.rb'

module Grammar
  module Operators
    class Division < ::Grammar::Operator
      def initialize(params)
        @params = params
        @r1_attr, @r2_attr = params.split(%r{ */ *})
        super()
      end

      def apply(r1, r2)
        validate_attribute_names(r1, r2)
        resulting_rel_attrs = r1.attributes_hash.select { |name, _type| name != @r1_attr.to_sym }
        new_rel = ::Relation.new(**resulting_rel_attrs)
        images = ::Hash.new { |hash, key| hash[key] = [] }
        r1.rows.each do |r1_row|
          images[resulting_rel_attrs.keys.map { |k| r1_row.public_send(k) }] << r1_row.public_send(@r1_attr)
        end
        second_set = r2.rows.map { |r2_row| r2_row.public_send(@r2_attr) }.uniq
        new_rel.bulk_insert(images.select { |key, im| (second_set - im).empty? }.keys)
        new_rel
      end

      def to_s
        "DIVISION(#{@params})"
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
    end
  end
end
