require 'grammar/operator.rb'

module Grammar
  module Operators
    class Projection < ::Grammar::Operator
      def initialize(params)
        @params = params
        super(1)
      end

      def apply(r)
        projection_attrs = @params.split(',')
        new_rel_attrs = r.attributes_hash.select { |name, type| projection_attrs.include?(name.to_s) }.to_h
        if (missing_attrs = projection_attrs.reject { |a| new_rel_attrs.keys.include?(a.to_sym) }).any?
          raise ArgumentError,
                "Cannot apply #{self.to_s}: relation's attributes do not include #{missing_attrs.join(', ')}"
        end
        new_rel = ::Relation.new(**new_rel_attrs)
        r.rows.each do |row|
          new_rel.insert(*new_rel_attrs.keys.map { |k| row.public_send(k) })
        end
        new_rel
      end

      def to_s
        "PROJECTION(#{@params})"
      end
    end
  end
end
