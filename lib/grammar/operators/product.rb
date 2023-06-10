require 'grammar/operator.rb'

module Grammar
  module Operators
    class Product < ::Grammar::Operator
      def apply(r1, r2)
        new_rel_attributes = {
          **r1.attributes_hash.transform_keys { |k| r2.attributes_hash.key?(k) ? "r1.#{k}".to_sym : k },
          **r2.attributes_hash.transform_keys { |k| r1.attributes_hash.key?(k) ? "r2.#{k}".to_sym : k }
        }
        new_rel = ::Relation.new(**new_rel_attributes)
        r1.rows.each do |r1_row|
          r2.rows.each do |r2_row|
            new_rel.insert(*r1_row.to_a, *r2_row.to_a)
          end
        end
        new_rel
      end
    end
  end
end
