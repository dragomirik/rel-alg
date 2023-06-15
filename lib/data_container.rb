class DataContainer
  def initialize(data_hash)
    @data = {}
    data_hash.each do |relation_name, relation|
      self[relation_name] = relation
    end
  end

  def [](name)
    @data[name.to_sym]
  end

  def []=(name, relation)
    relation.name = name
    @data[name.to_sym] = relation
  end

  def to_h
    @data
  end

  def to_s(reverse: false)
    relations = @data.values
    relations.reverse! if reverse
    relations.map(&:to_s).join("\n\n\n")
  end
end
