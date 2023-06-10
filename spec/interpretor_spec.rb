require 'interpretor.rb'

RSpec.describe ::Interpretor do
  context 'set operations' do
    let :users do
      ::Relation.new(id: :numeric, name: :string)
                .bulk_insert([
        [1, 'John'],
        [2, 'Jane'],
        [3, 'Peter']
      ])
    end

    let :admins do
      ::Relation.new(id: :numeric, name: :string)
                .bulk_insert([
        [1, 'John'],
        [2, 'Anne']
      ])
    end

    let :user_roles do
      ::Relation.new(role: :string)
                .bulk_insert([
        ['user'],
        ['manager']
      ])
    end

    let(:data) { { Users: users, Admins: admins, UserRoles: user_roles } }

    it 'should perform intersection correctly' do
      lines = ['Users & Admins -> Res']
      res_data = subject.run(lines, data)
      expect(res_data[:Res].to_a).to eq([{ id: 1, name: 'John' }])
    end

    it 'should perform union correctly' do
      lines = ['Users | Admins -> Res']
      res_data = subject.run(lines, data)
      expect(res_data[:Res].to_a).to eq([
        { id: 1, name: 'John' },
        { id: 2, name: 'Jane' },
        { id: 3, name: 'Peter' },
        { id: 2, name: 'Anne' }
      ])
    end

    it 'should perform difference corerctly' do
      lines = ['Users \ Admins -> Res']
      res_data = subject.run(lines, data)
      expect(res_data[:Res].to_a).to eq([
        { id: 2, name: 'Jane' },
        { id: 3, name: 'Peter' }
      ])
    end

    it 'should perform product correctly' do
      lines = ['Users * Admins -> Res']
      res_data = subject.run(lines, data)
      expect(res_data[:Res].to_a).to eq([
        { 'r1.id': 1, 'r1.name': 'John', 'r2.id': 1, 'r2.name': 'John' },
        { 'r1.id': 1, 'r1.name': 'John', 'r2.id': 2, 'r2.name': 'Anne' },
        { 'r1.id': 2, 'r1.name': 'Jane', 'r2.id': 1, 'r2.name': 'John' },
        { 'r1.id': 2, 'r1.name': 'Jane', 'r2.id': 2, 'r2.name': 'Anne' },
        { 'r1.id': 3, 'r1.name': 'Peter', 'r2.id': 1, 'r2.name': 'John' },
        { 'r1.id': 3, 'r1.name': 'Peter', 'r2.id': 2, 'r2.name': 'Anne' }
      ])
    end

    it 'should perform product correctly when all attribute names are unique' do
      lines = ['Users * UserRoles -> Res']
      res_data = subject.run(lines, data)
      expect(res_data[:Res].to_a).to eq([
        { id: 1, name: 'John', role: 'user' },
        { id: 1, name: 'John', role: 'manager' },
        { id: 2, name: 'Jane', role: 'user' },
        { id: 2, name: 'Jane', role: 'manager' },
        { id: 3, name: 'Peter', role: 'user' },
        { id: 3, name: 'Peter', role: 'manager' }
      ])
    end

    it 'should interpret a line with multiple set operations correctly' do
      lines = ['(Users \ Admins) | (Admins \ Users) -> Res']
      res_data = subject.run(lines, data)
      expect(res_data[:Res].to_a).to eq([
        { id: 2, name: 'Jane' },
        { id: 3, name: 'Peter' },
        { id: 2, name: 'Anne' }
      ])
    end

    it 'should perform multiple lines with set operations correctly' do
      lines = [
        'Users \ Admins -> R1',
        'Admins \ Users -> R2',
        'R1 | R2 -> Res'
      ]
      res_data = subject.run(lines, data)
      expect(res_data[:Res].to_a).to eq([
        { id: 2, name: 'Jane' },
        { id: 3, name: 'Peter' },
        { id: 2, name: 'Anne' }
      ])
    end

    context 'with relations whose columns do not match' do
      it 'should not perform difference' do
        expect { subject.run(['Users \ UserRoles -> Res'], data) }.to raise_error(
          ArgumentError, /Cannot apply DIFFERENCE: relations' attribute types don't match/
        )
      end

      it 'should not perform intersection' do
        expect { subject.run(['Users & UserRoles -> Res'], data) }.to raise_error(
          ArgumentError, /Cannot apply INTERSECTION: relations' attribute types don't match/
        )
      end

      it 'should not perform union' do
        expect { subject.run(['Users | UserRoles -> Res'], data) }.to raise_error(
          ArgumentError, /Cannot apply UNION: relations' attribute types don't match/
        )
      end
    end
  end
end
