require_relative 'attribute.rb'

class Relation
  attr_reader :rows, :attributes
  attr_accessor :name

  def initialize(**attributes)
    @attributes = attributes.map { |name, type| ::Attribute.new(name, type) }
    @rows = []
    @row_struct = ::Struct.new(*@attributes.map(&:name))
  end

  def bulk_insert(rows)
    rows.each { |row| insert(*row) }
    self
  end

  def insert(*row)
    row_to_insert = @row_struct.new(*row)
    @rows << row_to_insert unless @rows.include?(row_to_insert)
    self
  end

  def to_a
    @rows.map(&:to_h)
  end

  def to_s(with_name: name)
    col_widths = map_attributes { |name, _| [name, [name.to_s.size, *@rows.map { |r| r.public_send(name).to_s.size }].max] }.to_h
    [
      *("#{name}:\n" if with_name),
      map_attributes { |name, _| name.to_s.ljust(col_widths[name]) }.join(' | '),
      "#{'-' * (col_widths.values.reduce(:+) + (col_widths.values.size - 1) * 3)}",
      *@rows.map { |row| map_attributes { |name, _| row.public_send(name).to_s.ljust(col_widths[name]) }.join(' | ') },
      "(#{@rows.size} record(s))"
    ].join("\n")
  end

  def attribute_names
    @attribute_names ||= @attributes.map(&:name)
  end

  def attributes_hash
    @attributes_hash ||= @attributes.map { |a| [a.name, a.type] }.to_h
  end

  private

  def map_attributes(&block)
    @attributes.map { |a| [a.name, a.type] }.map(&block)
  end
end
