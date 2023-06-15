require 'relation.rb'

require 'pry'

RSpec.describe ::Relation do
  describe '#to_s' do
    subject { described_class.new(id: :numeric, name: :string, year_of_birth: :numeric) }

    it 'should display an empty relation correclty' do
      expect(subject.to_s).to eq(
        "id | name | year_of_birth\n"\
        "-------------------------\n"\
        "(0 record(s))"
      )
    end

    it 'should display a relation with one record correctly' do
      subject.insert(1, 'John Smith', 1996)
      expect(subject.to_s).to eq(
        "id | name       | year_of_birth\n"\
        "-------------------------------\n"\
        "1  | John Smith | 1996         \n"\
        "(1 record(s))"
      )
    end

    it 'should display a relation with multiple records correctly' do
      subject.bulk_insert([
        [1, 'John Smith', 1996],
        [1002, 'Jane Doe', 1987],
        [3, 'Sir Isaac Newton', 1642]
      ])
      expect(subject.to_s).to eq(
        "id   | name             | year_of_birth\n"\
        "---------------------------------------\n"\
        "1    | John Smith       | 1996         \n"\
        "1002 | Jane Doe         | 1987         \n"\
        "3    | Sir Isaac Newton | 1642         \n"\
        "(3 record(s))"
      )
    end

    it 'should display a relation with a name correctly' do
      subject.insert(1, 'John Smith', 1996)
      subject.name = :Users
      expect(subject.to_s).to eq(
        "Users:\n"\
        "\n"\
        "id | name       | year_of_birth\n"\
        "-------------------------------\n"\
        "1  | John Smith | 1996         \n"\
        "(1 record(s))"
      )
    end
  end
end
