class Attribute
  TYPES = [:numeric, :string, :date].freeze

  attr_reader :name, :type

  def initialize(name, type)
    @name = name
    unless (@type = resolve_type(type))
      raise "Unable to resolve type for attribute '#{name}': #{type}"
    end
  end

  private

  def resolve_type(type)
    if TYPES.include?(type.to_sym)
      type.to_sym
    end
  end
end
