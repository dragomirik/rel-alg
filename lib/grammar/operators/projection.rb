require_relative '../operator.rb'

module Grammar
  module Operators
    class Projection < ::Grammar::Operator
      def initialize(params)
        @params = params
        super(1)
      end

      def apply(r)
        projection_attrs = @params.split(',')
        new_rel_attrs = projection_attrs.map do |projection_attr|
          type = r.attributes_hash[projection_attr.to_sym]
          next unless type
          [projection_attr.to_sym, type]
        end.compact.to_h
        if (missing_attrs = projection_attrs.reject { |a| new_rel_attrs.keys.include?(a.to_sym) }).any?
          raise ::Errors::OperatorError.new(to_s, "relation's attributes do not include #{missing_attrs.join(', ')}")
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
