#================================Binary OPERATIONS=============================================
class BinaryOperator
  attr_reader :left, :right, :start_index, :end_index

  def initialize(left, right, start_index = nil, end_index = nil)
    @left = left
    @right = right
    @start_index = start_index
    @end_index = end_index
  end

  def traverse(visitor, runtime)
    visitor.send("visit_#{self.class.name.gsub('Operation', '').downcase}", self, runtime)
  end
end

class AdditionOperation < BinaryOperator; end
class SubtractionOperation < BinaryOperator; end
class MultiplicationOperation < BinaryOperator; end
class DivisionOperation < BinaryOperator; end
class ModuloOperation < BinaryOperator; end
class ExponentiationOperation < BinaryOperator; end
class AndOperation < BinaryOperator; end
class OrOperation < BinaryOperator; end
class EqualsOperation < BinaryOperator; end
class NotEqualsOperation < BinaryOperator; end
class LessThanOperation < BinaryOperator; end
class LessThanOrEqualOperation < BinaryOperator; end
class MoreThanOperation < BinaryOperator; end
class MoreThanOrEqualOperation < BinaryOperator; end
class BitwiseAnd < BinaryOperator; end
class BitwiseOr < BinaryOperator; end
class BitwiseXor < BinaryOperator; end
class BitwiseLeftShift < BinaryOperator; end
class BitwiseRightShift < BinaryOperator; end
class RValue < BinaryOperator; end
class LValue < BinaryOperator; end
class CellAddressPrimitive < BinaryOperator; end
class MaxOperation < BinaryOperator; end
class MinOperation < BinaryOperator; end
class MeanOperation < BinaryOperator; end
class SumOperation < BinaryOperator; end

#================================UNARY OPERATIONS=============================================

class UnaryOperator
  attr_reader :value, :start_index, :end_index

  def initialize(value, start_index = nil, end_index = nil)
    @value = value
    @start_index = start_index
    @end_index = end_index
  end

  def traverse(visitor, runtime)
    visitor.send("visit_#{self.class.name.gsub('Operation', '').downcase}", self, runtime)
  end
end


class NegationOperation < UnaryOperator; end
class NotOperation < UnaryOperator; end
class FloatToInt < UnaryOperator; end
class IntToFloat < UnaryOperator; end
class BitwiseNot < UnaryOperator; end
class IntegerPrimitive < UnaryOperator; end
class FloatPrimitive < UnaryOperator; end
class BooleanPrimitive < UnaryOperator; end
class StringPrimitive < UnaryOperator; end

#================================ Variables & Flow=============================================

class Block
  attr_reader :statements, :start_index, :end_index

  def initialize(statements, start_index = nil, end_index = nil)
    @statements = statements
    @start_index = start_index
    @end_index = end_index
  end

  def add(statement)
    @statements << statement
  end

  def traverse(visitor, runtime)
    visitor.send("visit_#{self.class.name.downcase}", self, runtime)
  end
end

class Assignment
  attr_reader :variable, :statement, :start_index, :end_index

  def initialize(variable, statement, start_index = nil, end_index = nil)
    @variable = variable
    @statement = statement
    @start_index = start_index
    @end_index = end_index
  end

  def traverse(visitor, runtime)
    visitor.send("visit_#{self.class.name.downcase}", self, runtime)
  end
end

class Reference
  attr_reader :variable, :start_index, :end_index

  def initialize(variable, start_index = nil, end_index = nil)
    @variable = variable
    @start_index = start_index
    @end_index = end_index
  end

  def traverse(visitor, runtime)
    visitor.send("visit_#{self.class.name.downcase}", self, runtime)
  end

end

class Conditional
  attr_reader :condition, :if_block, :else_block, :start_index, :end_index

  def initialize(condition, if_block, else_block = nil, start_index = nil, end_index = nil)
    @condition = condition
    @if_block = if_block
    @else_block = else_block
    @start_index = start_index
    @end_index = end_index
  end

  def traverse(visitor, runtime)
    visitor.send("visit_#{self.class.name.downcase}", self, runtime)
  end
end

class ForLoop
  attr_reader :iterator, :start_row, :start_col, :end_row, :end_col, :body

  def initialize(iterator, start_row, start_col, end_row, end_col, body)
    @iterator = iterator
    @start_row = start_row
    @start_col = start_col
    @end_row = end_row
    @end_col = end_col
    @body = body
  end

  def traverse(visitor, runtime)
    visitor.visit_for_loop(self, runtime)
  end
end