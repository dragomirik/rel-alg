require_relative 'grammar/parser.rb'
require_relative 'data_container'
require_relative 'errors'

class Interpreter
  def run(lines, data)
    data = ::DataContainer.new(data)
    sanitize_program_lines(lines).each.with_index(1) do |line, i|
      expression, relation_name = line.split(/ *-> */)
      rpn = ::Grammar::Parser.parse(expression)
      resulting_relation = evaluate(rpn, data)
      data[relation_name.strip.to_sym] = resulting_relation if relation_name
    rescue => e
      raise ::Errors::InterpretationError.new(e, line, i, data)
    end
    data
  end

  private

  def sanitize_program_lines(lines)
    lines.map do |line|
      line = line.sub(%r{//.*$}, '').strip # remove comments
      next unless line.length > 0
      SANITIZED_CHARACTERS.reduce(line) { |l, (c_in, c_out)| l.gsub(c_in, c_out) }
    end.compact
  end

  def evaluate(reverse_polish_notation, data)
    execution_stack = []
    reverse_polish_notation.map { |term|
      if term.is_a?(::Grammar::Operator)
        term
      else
        relation = data[term]
        if relation.nil?
          raise ::Errors::UnknownRelationError.new(term, data)
        end
        relation
      end
    }.each do |term|
      if term.is_a?(::Grammar::Operator)
        execution_stack.push(term.apply(*execution_stack.pop(term.arity)))
      else
        execution_stack.push(term)
      end
    end
    if execution_stack.size != 1
      raise "RPN expression invalid: execution stack at the end of evaluation "\
            "has size #{execution_stack.size}.\nRPN: #{reverse_polish_notation.map(&:to_s)}"
    end
    execution_stack[0]
  end

  SANITIZED_CHARACTERS = {
    '÷' => '/',
    '∪' => '|',
    '∩' => '&',
    '×' => '*',
    '⟶' => '->',
    '‘' => "'",
    '’' => "'"
  }.freeze
end
