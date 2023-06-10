require 'grammar/parser.rb'

class Interpretor
  def run(lines, data)
    lines.each do |line|
      expression, relation_name = line.split(/ *-> */)
      rpn = ::Grammar::Parser.parse(expression)
      data[relation_name.strip.to_sym] = evaluate(rpn, data)
    end
    data
  end

  private

  def evaluate(reverse_polish_notation, data)
    execution_stack = []
    reverse_polish_notation.map { |term|
      term.is_a?(::Grammar::Operator) ? term : data[term.to_sym]
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
end
