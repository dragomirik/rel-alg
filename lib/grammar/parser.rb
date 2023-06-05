require 'grammar/errors.rb'
require 'grammar/operator.rb'
require 'grammar/operators/difference.rb'
require 'grammar/operators/division.rb'
require 'grammar/operators/intersection.rb'
require 'grammar/operators/join.rb'
require 'grammar/operators/limit.rb'
require 'grammar/operators/product.rb'
require 'grammar/operators/projection.rb'
require 'grammar/operators/union.rb'

module Grammar
  class Parser
    def self.parse(expression)
      new(expression).parse
    end

    def parse
      @expression.each_char.with_index do |char, i|
        case char
        when ' '
          appent_to_current_string(char) if @inside_quotes
        when /[\w='\/]/
          appent_to_current_string(char)
          @inside_quotes = !@inside_quotes if char == "'"
        when '('
          @operator_stack.push(char)
        when ')'
          push_current_expression_to_output_queue
          pop_operators_up_to_opening_parenthesis
        when '\\', '&', '|', '*'
          push_current_expression_to_output_queue
          pop_operators_up_to_opening_parenthesis
          @operator_stack.push(OPERATORS[char.to_sym].new)
        when '['
          push_current_expression_to_output_queue
          @reading_operator_params = true
        when ']'
          @operator_stack.push(relational_operator(i))
          @reading_operator_params = false
        end
      end
      push_current_expression_to_output_queue
      @output_queue + @operator_stack.reverse
    end

    private

    def initialize(expression)
      @expression = expression
      @output_queue   = []
      @operator_stack = []
      @current_expression      = ''
      @current_operator_params = ''
      @reading_operator_params = false
      @inside_quotes = false
    end

    def appent_to_current_string(current_char)
      if @reading_operator_params
        @current_operator_params += current_char
      else
        @current_expression += current_char
      end
    end

    def push_current_expression_to_output_queue
      @output_queue.push(@current_expression) if @current_expression.size > 0
      @current_expression = ''
    end

    def pop_operators_up_to_opening_parenthesis
      while (last_operator = @operator_stack.pop)
        break if last_operator == '('
        @output_queue.push(last_operator)
      end
    end

    def relational_operator(current_index)
      klass = case @current_operator_params
              when /\//
                ::Grammar::Operators::Division
              when /[<>=!]/
                if @expression[(current_index + 1)..-1].match?(/^ *\)* *\w/)
                  ::Grammar::Operators::Join
                else
                  ::Grammar::Operators::Limit
                end
              else
                ::Grammar::Operators::Projection
              end
      operator = klass.new(@current_operator_params)
      @current_operator_params = ''
      operator
    end

    OPERATORS = {
      :'\\' => ::Grammar::Operators::Difference,
      :& => ::Grammar::Operators::Intersection,
      :| => ::Grammar::Operators::Union,
      :* => ::Grammar::Operators::Product
    }.freeze
  end
end
