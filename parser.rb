require_relative 'lexer'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @current = 0
    @block = Block.new([])
  end

  def parse
    block
  end

  def has(type)
    !at_end? && @tokens[@current].type == type
  end

  def expect(type)
    if has(type)
      token = current_token
      advance
      token
    else
      error("Expected #{type} but found #{current_token.type}")
    end
  end  

  def has_next(type)
    !(@current >= @tokens.length - 1) && @tokens[@current + 1].type == type
  end

  def advance
    @current += 1 unless at_end?
  end

  def at_end?
    @current >= @tokens.length
  end

  def current_token
    @tokens[@current]
  end

  def error(message)
    token = current_token
    raise "Error: #{message} at index #{token.start_index}"
  end

  def block
    statements = []
  
    while !at_end?
      while has(:linebreak)
        advance
      end
  
      break if has(:end) || has(:else)
  
      if has(:if)
        statements << parse_conditional
      elsif has(:for)
        statements << parse_for_loop
      elsif has(:identifier) && has_next(:assignment)
        statements << assignment
      else
        statements << expression
      end
    end
  
    Block.new(statements)
  end
  
  def parse_for_loop
    expect(:for)
    iterator = expect(:identifier)
    expect(:in)
    expect(:left_square_bracket)
    start_row = expect(:number)
    expect(:comma)
    start_col = expect (:number)
    expect(:right_square_bracket)

    expect(:dot_dot)

    expect(:left_square_bracket)
    end_row = expect(:number)
    expect(:comma)
    end_col = expect (:number)
    expect(:right_square_bracket)
    
    if has(:do) || has(:linebreak)
      advance
    else
      error("Expected 'do' or a linebreak in 'for' loop")
    end
  
    body = block
    expect(:end)
  
    ForLoop.new(iterator, start_row, start_col, end_row, end_col, body)
  end
  
  def parse_conditional
    if has(:if)
      advance
  
      condition = expression
      unless has(:linebreak)
        error("Expected a linebreak after the condition")
      end
      advance
  
      if_block = block
  
      else_block = nil
      if has(:else)
        advance
        unless has(:linebreak)
          error("Expected a linebreak after 'else'")
        end
        advance
        else_block = block
      end
  
      unless has(:end)
        error("Expected 'end' to close the conditional")
      end
      advance
  
      Conditional.new(condition, if_block, else_block)
    else
      error("Expected 'if' at the start of a conditional")
    end
  end
  
  def assignment
    variable = current_token
    advance
    advance
    final = expression
    Assignment.new(variable, final)
  end

  def expression
    level1
  end

  # Logical AND, OR (Level 1)
  def level1
    left = level2
    while has(:and) || has(:or)
      operator = current_token
      advance
      right = level2
      case operator.type
      when :and
        left = AndOperation.new(left, right, operator.start_index, operator.end_index)
      when :or
        left = OrOperation.new(left, right, operator.start_index, operator.end_index)
      end
    end
    left
  end

  # Equality and Relational Operators (Level 2)
  def level2
    left = level3
    while has(:equal_sign) || has(:not_equal) || has(:less_than) || has(:less_than_equal) ||
          has(:more_than) || has(:more_than_equal)
      operator = current_token
      advance
      right = level3
      case operator.type
      when :equal_sign
        left = EqualsOperation.new(left, right, operator.start_index, operator.end_index)
      when :not_equal
        left = NotEqualsOperation.new(left, right, operator.start_index, operator.end_index)
      when :less_than
        left = LessThanOperation.new(left, right, operator.start_index, operator.end_index)
      when :less_than_equal
        left = LessThanOrEqualOperation.new(left, right, operator.start_index, operator.end_index)
      when :more_than
        left = MoreThanOperation.new(left, right, operator.start_index, operator.end_index)
      when :more_than_equal
        left = MoreThanOrEqualOperation.new(left, right, operator.start_index, operator.end_index)
      end
    end
    left
  end

  # Arithmetic Addition and Subtraction (Level 3)
  def level3
    left = level4
    while has(:plus) || has(:minus)
      operator = current_token
      advance
      right = level4
      case operator.type
      when :plus
        left = AdditionOperation.new(left, right, operator.start_index, operator.end_index)
      when :minus
        left = SubtractionOperation.new(left, right, operator.start_index, operator.end_index)
      end
    end
    left
  end

  # Multiplication, Division, Modulus (Level 4)
  def level4
    left = level5
    while has(:asterisk) || has(:slash) || has(:percent) || has(:double_asterisk)
      operator = current_token
      advance
      right = level5
      case operator.type
      when :asterisk
        left = MultiplicationOperation.new(left, right, operator.start_index, operator.end_index)
      when :slash
        left = DivisionOperation.new(left, right, operator.start_index, operator.end_index)
      when :percent
        left = ModuloOperation.new(left, right, operator.start_index, operator.end_index)
      when :double_asterisk
        left = ExponentiationOperation.new(left, right, operator.start_index, operator.end_index)
      end
    end
    left
  end

  # Bitwise operations (Level 5)
  def level5
    left = level6
    while has(:ampersand) || has(:pipe) || has(:caret) || has(:left_shift) || has(:right_shift)
      operator = current_token
      advance
      right = level6
      case operator.type
      when :ampersand
        left = BitwiseAnd.new(left, right, operator.start_index, operator.end_index)
      when :pipe
        left = BitwiseOr.new(left, right, operator.start_index, operator.end_index)
      when :caret
        left = BitwiseXor.new(left, right, operator.start_index, operator.end_index)
      when :left_shift
        left = BitwiseLeftShift.new(left, right, operator.start_index, operator.end_index)
      when :right_shift
        left = BitwiseRightShift.new(left, right, operator.start_index, operator.end_index)
      end
    end
    left
  end

  # Logical NOT, Negation, Bitwise NOT (Level 6)
  def level6
    if has(:exclamation)
      operator = current_token
      advance
      operand = level6
      return NotOperation.new(operand, operator.start_index, operator.end_index)
    elsif has(:minus)
      operator = current_token
      advance
      operand = level6
      return NegationOperation.new(operand, operator.start_index, operator.end_index)
    elsif has(:tilde)
      operator = current_token
      advance
      operand = level6
      return BitwiseNot.new(operand, operator.start_index, operator.end_index)
    else
      return level7
    end
  end

  # Casting Operations (Level 7)
  def level7
    if has(:float)
      advance
      if has(:left_parenthesis)
        advance
        param = expression
        if has(:right_parenthesis)
          advance
          return IntToFloat.new(param)
        else
          error("Expected closing parenthesis after float")
        end
      else
        error("Expected '(' after float")
      end
    elsif has(:int)
      advance
      if has(:left_parenthesis)
        advance
        param = expression
        if has(:right_parenthesis)
          advance
          return FloatToInt.new(param)
        else
          error("Expected closing parenthesis after int")
        end
      else
        error("Expected '(' after int")
      end
    else
      return level8
    end
  end

  # Parentheses, Primitives, RValue, LValue, Statistical Functions (Level 8)
  def level8
    if has(:linebreak)
      advance
      expression
    elsif has(:left_parenthesis)
      advance
      expr = expression
      if has(:right_parenthesis)
        advance
        return expr
      else
        error("Expected closing parenthesis")
      end
    elsif has(:hash_bracket_start) # #[expression, expression]
      advance
      first_param = expression
      advance if has(:comma)
      second_param = expression
      if has(:right_square_bracket)
        advance
        return RValue.new(first_param, second_param)
      else
        error("Expected closing ']' for RValue")
      end
    elsif has(:left_square_bracket) # [expression, expression]
      advance
      first_param = expression
      advance if has(:comma)
      second_param = expression
      if has(:right_square_bracket)
        advance
        return LValue.new(first_param, second_param)
      else
        error("Expected closing ']' for LValue")
      end
    elsif has(:sum) || has(:mean) || has(:min) || has(:max) # Statistical functions
      function_name = current_token.text
      advance
      if has(:left_parenthesis)
        advance
        first_param = expression
        advance if has(:comma)
        second_param = expression
        if has(:right_parenthesis)
          advance
          case function_name
          when "sum"
            return SumOperation.new(first_param, second_param)
          when "mean"
            return MeanOperation.new(first_param, second_param)
          when "min"
            return MinOperation.new(first_param, second_param)
          when "max"
            return MaxOperation.new(first_param, second_param)
          else
            error("Unknown function #{function_name}")
          end
        else
          error("Expected closing parenthesis for #{function_name} function")
        end
      else
        error("Expected '(' after #{function_name}")
      end
    else
      # Handle primitives
      token = current_token
      case token.type
      when :number
        advance
        return IntegerPrimitive.new(token.text.to_i, token.start_index, token.end_index)
      when :float
        advance
        return FloatPrimitive.new(token.text.to_f, token.start_index, token.end_index)
      when :true, :false
        advance
        return BooleanPrimitive.new(token.text == "true", token.start_index, token.end_index)
      when :identifier
        advance
        return Reference.new(token.text, token.start_index, token.end_index)
      else
        error("Unexpected token")
      end
    end
  end
end
