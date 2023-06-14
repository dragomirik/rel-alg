require_relative '../operator.rb'

module Grammar
  module Operators
    class Difference < ::Grammar::Operator
      def apply(r1, r2)
        unless r1.attributes.map(&:type) == r2.attributes.map(&:type)
          raise ArgumentError,
                "Cannot apply #{self.to_s}: relations' attribute types don't match\n"\
                "Relation 1: #{r1.attributes.map(&:type)}\n"\
                "Relation 2: #{r2.attributes.map(&:type)}"
        end
        new_rel = ::Relation.new(**r1.attributes_hash)
        rows_to_insert = r1.rows.reject do |r1_row|
          r2.rows.find do |r2_row|
            r1.attribute_names.all? { |k| r1_row.public_send(k) == r2_row.public_send(k) }
          end
        end
        new_rel.bulk_insert(rows_to_insert.map(&:to_a))
      end
    end
  end
end
