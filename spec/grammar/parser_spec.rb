require 'grammar/parser.rb'

RSpec.describe ::Grammar::Parser do
  subject { described_class }

  context 'parsing relation names' do
    it 'should parse one-letter relation names' do
      expect(subject.parse('R')).to eq(['R'])
    end

    it 'should parse multiple letter relation names' do
      expect(subject.parse('Rel')).to eq(['Rel'])
    end
  end

  context 'parsing simple set operations' do
    it 'should parse difference correctly' do
      expect(subject.parse('Init \ Rel2').map(&:to_s)).to eq(%w[Init Rel2 DIFFERENCE])
    end

    it 'should parse intersection correctly' do
      expect(subject.parse('A&B').map(&:to_s)).to eq(%w[A B INTERSECTION])
    end

    it 'should parse union correctly' do
      expect(subject.parse('R |Res2').map(&:to_s)).to eq(%w[R Res2 UNION])
    end

    it 'should parse product correctly' do
      expect(subject.parse(' Rel1*  Rel2').map(&:to_s)).to eq(%w[Rel1 Rel2 PRODUCT])
    end
  end

  context 'parsing expressions including multiple set operations' do
    it 'should parse expression with two consequent operations correctly' do
      expect(subject.parse('A & B | C').map(&:to_s)).to eq(%w[A B INTERSECTION C UNION])
    end

    it 'should parse expression with parentheses correctly' do
      expect(subject.parse('Rel1 \ (Rel2 & Rel3)').map(&:to_s)).to eq(%w[Rel1 Rel2 Rel3 INTERSECTION DIFFERENCE])
    end
  end

  context 'parsing projection' do
    it 'should parse projection correctly' do
      expect(subject.parse('R[id]').map(&:to_s)).to eq(%w[R PROJECTION(id)])
    end

    it 'should parse projection with multiple attributes correctly' do
      expect(subject.parse('R[id,name]').map(&:to_s)).to eq(%w[R PROJECTION(id,name)])
    end

    it 'should parse projection with multiple attributes with whitespaces correctly' do
      expect(subject.parse('R[id,name, something_else]').map(&:to_s)).to eq(%w[R PROJECTION(id,name,something_else)])
    end
  end

  context 'parsing limit' do
    it 'should parse limit correctly' do
      expect(subject.parse('Rel[id=second_id]').map(&:to_s)).to eq(%w[Rel LIMIT(id=second_id)])
    end

    it 'should parse shortened limit correctly' do
      expect(subject.parse("Rel[name='John']").map(&:to_s)).to eq(%w[Rel LIMIT(name='John')])
    end
  end

  context 'parsing join' do
    it 'should parse join correctly' do
      expect(subject.parse('Rel1[id=id]Rel2').map(&:to_s)).to eq(%w[Rel1 Rel2 JOIN(id=id)])
    end
  end

  context 'parsing division' do
    it 'should parse division correctly' do
      expect(subject.parse('R1[a1/a2]R2').map(&:to_s)).to eq(%w[R1 R2 DIVISION(a1/a2)])
    end
  end

  context 'parsing complex relational algebra expressions' do
    {
      '(Parent[id])[id=parent_id]Child' => %w[Parent PROJECTION(id) Child JOIN(id=parent_id)],
      "(Rel1[name = 'Name'])[ index]" => %w[Rel1 LIMIT(name='Name') PROJECTION(index)],
      "(Rel1[name = 'With Whitespaces'])[ index]" => ['Rel1', "LIMIT(name='With Whitespaces')", 'PROJECTION(index)'],
      "(R_1 [id1 = id2] R_2)[index]" => %w[R_1 R_2 JOIN(id1=id2) PROJECTION(index)]
    }.each do |expression, rpn|
      it "should correctly parse #{expression}" do
        expect(subject.parse(expression).map(&:to_s)).to eq(rpn)
      end
    end
  end
end
