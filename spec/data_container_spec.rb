require 'data_container'

RSpec.describe ::DataContainer do
  let :users do
    ::Relation.new(id: :numeric, name: :string)
              .bulk_insert([
      [1, 'John'],
      [2, 'Jane'],
      [3, 'Peter']
    ])
  end

  let :user_roles do
    ::Relation.new(role: :string)
              .bulk_insert([
      ['user'],
      ['manager']
    ])
  end

  describe '#initialize' do
    it 'should provide access to relations' do
      container = described_class.new(Users: users, UserRoles: user_roles)
      expect(container[:Users]).to be_a(::Relation)
      expect(container[:Users].name).to eq(:Users)
      expect(container[:Users].rows.size).to eq(3)
      expect(container[:Users]).to eq(container['Users'])
    end
  end

  describe '#[]=' do
    it 'should give names to relations' do
      container = described_class.new(Users: users)
      expect { container[:UserRoles] = user_roles }
        .to change { user_roles.name }.from(nil).to(:UserRoles)
      expect(container[:UserRoles]).to be_a(::Relation)
      expect(container[:UserRoles].rows.size).to eq(2)
    end
  end
end
