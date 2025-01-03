require_relative 'grid'
require_relative 'BinaryUnary'

class Evaluator

  attr_accessor :grid

  def initialize(grid)
    @grid = grid
  end

  ## ================================ Primitives =====================================
  def visit_integerprimitive(integer_primitive, runtime)
    integer_primitive
  end

  def visit_floatprimitive(float_primitive, runtime)
    float_primitive
  end

  def visit_booleanprimitive(boolean_primitive, runtime)
    boolean_primitive
  end

  def visit_stringprimitive(string_primitive, runtime)
    string_primitive
  end

  def visit_celladdressprimitive(cell_address_primitive, runtime)
    cell_address_primitive
  end

  ## ================================ Arithmetic Operations =====================================

  def visit_addition(addition, runtime)
    left_value = addition.left.traverse(self, runtime)
    right_value = addition.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive))
      raise "Invalid left type for addition, it is a #{left_value.class}"
    end
    if !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid right type for addition, it is a #{right_value.class}"
    end

    result_value = left_value.value + right_value.value
    result_value.is_a?(Float) ? FloatPrimitive.new(result_value) : IntegerPrimitive.new(result_value)
  end

  def visit_subtraction(subtraction, runtime)
    left_value = subtraction.left.traverse(self, runtime)
    right_value = subtraction.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive))
      raise "Invalid type for subtraction"
    end
    if !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid type for subtraction"
    end

    result_value = left_value.value - right_value.value
    result_value.is_a?(Float) ? FloatPrimitive.new(result_value) : IntegerPrimitive.new(result_value)
  end

  def visit_multiplication(multiplication, runtime)
    left_value = multiplication.left.traverse(self, runtime)
    right_value = multiplication.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive))
      raise "Invalid type for multiplication: #{left_value.is_a?}"
    end
    if !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid type for multiplication"
    end

    result_value = left_value.value * right_value.value
    result_value.is_a?(Float) ? FloatPrimitive.new(result_value) : IntegerPrimitive.new(result_value)
  end

  def visit_division(division, runtime)
    left_value = division.left.traverse(self, runtime)
    right_value = division.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive))
      raise "Invalid type for division"
    end
    if !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid type for division"
    end

    result_value = left_value.value.to_f / right_value.value.to_f
    FloatPrimitive.new(result_value)
  end

  def visit_modulo(modulo, runtime)
    left_value = modulo.left.traverse(self, runtime)
    right_value = modulo.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive))
      raise "Invalid type for modulo"
    end
    if !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid type for modulo"
    end

    result_value = left_value.value % right_value.value
    IntegerPrimitive.new(result_value)
  end

  def visit_exponentiation(exponentiation, runtime)
    left_value = exponentiation.left.traverse(self, runtime)
    right_value = exponentiation.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive))
      raise "Invalid type for exponentiation"
    end
    if !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid type for exponentiation"
    end

    result_value = left_value.value ** right_value.value
    result_value.is_a?(Float) ? FloatPrimitive.new(result_value) : IntegerPrimitive.new(result_value)
  end

  def visit_negation(negation, runtime)
    value = negation.value.traverse(self, runtime)

    if !(value.is_a?(IntegerPrimitive) || value.is_a?(FloatPrimitive))
      raise "Invalid type for negation"
    end

    result_value = value.value * -1
    result_value.is_a?(Float) ? FloatPrimitive.new(result_value) : IntegerPrimitive.new(result_value)
  end

  ## ================================ Relational Operations =====================================

  def visit_equals(equals, runtime)
    left_value = equals.left.traverse(self, runtime)
    right_value = equals.right.traverse(self, runtime)

    if left_value.class != right_value.class
      raise "Equals operands not the same type"
    end

    BooleanPrimitive.new(left_value.value == right_value.value)
  end

  def visit_notequals(not_equals, runtime)
    left_value = not_equals.left.traverse(self, runtime)
    right_value = not_equals.right.traverse(self, runtime)

    if left_value.class != right_value.class
      raise "Not equals operands not the same type"
    end

    BooleanPrimitive.new(left_value.value != right_value.value)
  end

  def visit_lessthan(less_than, runtime)
    left_value = less_than.left.traverse(self, runtime)
    right_value = less_than.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive)) || !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid type for less than comparison"
    end

    BooleanPrimitive.new(left_value.value < right_value.value)
  end

  def visit_lessthanorequal(less_than_or_equal, runtime)
    left_value = less_than_or_equal.left.traverse(self, runtime)
    right_value = less_than_or_equal.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive)) || !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid type for less than or equal comparison"
    end

    BooleanPrimitive.new(left_value.value <= right_value.value)
  end

  def visit_morethan(more_than, runtime)
    left_value = more_than.left.traverse(self, runtime)
    right_value = more_than.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive)) || !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid type for more than comparison"
    end

    BooleanPrimitive.new(left_value.value > right_value.value)
  end

  def visit_morethanorequal(more_than_or_equal, runtime)
    left_value = more_than_or_equal.left.traverse(self, runtime)
    right_value = more_than_or_equal.right.traverse(self, runtime)

    if !(left_value.is_a?(IntegerPrimitive) || left_value.is_a?(FloatPrimitive)) || !(right_value.is_a?(IntegerPrimitive) || right_value.is_a?(FloatPrimitive))
      raise "Invalid type for more than or equal comparison"
    end

    BooleanPrimitive.new(left_value.value >= right_value.value)
  end

  ## ================================ Bitwise Operations =====================================

  def visit_bitwiseand(bitwise_and, runtime)
    left_value = bitwise_and.left.traverse(self, runtime)
    right_value = bitwise_and.right.traverse(self, runtime)
  
    if !(left_value.is_a?(IntegerPrimitive)) || !(right_value.is_a?(IntegerPrimitive))
      raise "Invalid type for bitwise and"
    end
  
    IntegerPrimitive.new(left_value.value & right_value.value)
  end

  def visit_bitwiseor(bitwise_or, runtime)
    left_value = bitwise_or.left.traverse(self, runtime)
    right_value = bitwise_or.right.traverse(self, runtime)
  
    if !(left_value.is_a?(IntegerPrimitive)) || !(right_value.is_a?(IntegerPrimitive))
      raise "Invalid type for bitwise or"
    end
  
    IntegerPrimitive.new(left_value.value | right_value.value)
  end

  def visit_bitwisexor(bitwise_xor, runtime)
    left_value = bitwise_xor.left.traverse(self, runtime)
    right_value = bitwise_xor.right.traverse(self, runtime)
  
    if !(left_value.is_a?(IntegerPrimitive)) || !(right_value.is_a?(IntegerPrimitive))
      raise "Invalid type for bitwise xor"
    end
  
    IntegerPrimitive.new(left_value.value ^ right_value.value)
  end

  def visit_bitwisenot(bitwise_not, runtime)
    value = bitwise_not.value.traverse(self, runtime)
  
    if !(value.is_a?(IntegerPrimitive))
      raise "Invalid type for bitwise not"
    end
  
    IntegerPrimitive.new(~value.value)
  end

  def visit_bitwiseleftshift(bitwise_left_shift, runtime)
    value = bitwise_left_shift.left.traverse(self, runtime)
    number_of_shifts = bitwise_left_shift.right.traverse(self, runtime)
  
    if !(value.is_a?(IntegerPrimitive)) || !(number_of_shifts.is_a?(IntegerPrimitive))
      raise "Invalid type for bitwise left shift"
    end
  
    IntegerPrimitive.new(value.value << number_of_shifts.value)
  end

  def visit_bitwiserightshift(bitwise_right_shift, runtime)
    value = bitwise_right_shift.left.traverse(self, runtime)
    number_of_shifts = bitwise_right_shift.right.traverse(self, runtime)
  
    if !(value.is_a?(IntegerPrimitive)) || !(number_of_shifts.is_a?(IntegerPrimitive))
      raise "Invalid type for bitwise right shift"
    end
  
    IntegerPrimitive.new(value.value >> number_of_shifts.value)
  end

  ## ================================ Casting Operations =====================================

  def visit_floattoint(float_to_int, runtime)
    value = float_to_int.value.traverse(self, runtime)
    if !(value.is_a?(FloatPrimitive))
      raise "Invalid type for casting float to int"
    end
    IntegerPrimitive.new(value.value.to_i)
  end
  
  def visit_inttofloat(int_to_float, runtime)
    value = int_to_float.value.traverse(self, runtime)
    if !(value.is_a?(IntegerPrimitive))
      raise "Invalid type for casting int to float"
    end
    FloatPrimitive.new(value.value.to_f)
  end

  ## ================================ Statistics Functions =====================================

  def visit_max(max, runtime)
    start_cell = max.left.traverse(self, runtime)
    end_cell = max.right.traverse(self, runtime)
  
    start_row, start_col = start_cell.left.value, start_cell.right.value
    end_row, end_col = end_cell.left.value, end_cell.right.value
  
    values = []
  
    for row in start_row..end_row
      for col in start_col..end_col
        cell_value = runtime.get_cell_value(row, col)
        if cell_value.is_a?(IntegerPrimitive) || cell_value.is_a?(FloatPrimitive)
          values << cell_value.value
        elsif !cell_value.nil? && cell_value != ""
          # puts "Warning: Non-numeric value encountered in cell [#{row}, #{col}], ignoring in max calculation"
        end
      end
    end
  
    if values.empty?
      raise "Error: No numeric values found in the given range for max calculation"
    end
  
    max_value = values.max
    max_value.is_a?(Float) ? FloatPrimitive.new(max_value) : IntegerPrimitive.new(max_value)
  end
  
  def visit_min(min, runtime)
    start_cell = min.left.traverse(self, runtime)
    end_cell = min.right.traverse(self, runtime)
  
    start_row, start_col = start_cell.left.value, start_cell.right.value
    end_row, end_col = end_cell.left.value, end_cell.right.value
  
    values = []
  
    for row in start_row..end_row
      for col in start_col..end_col
        cell_value = runtime.get_cell_value(row, col)
        if cell_value.is_a?(IntegerPrimitive) || cell_value.is_a?(FloatPrimitive)
          values << cell_value.value
        elsif !cell_value.nil? && cell_value != ""
          # puts "Warning: Non-numeric value encountered in cell [#{row}, #{col}], ignoring in min calculation"
        end
      end
    end
  
    if values.empty?
      raise "Error: No numeric values found in the given range for min calculation"
    end
  
    min_value = values.min
    min_value.is_a?(Float) ? FloatPrimitive.new(min_value) : IntegerPrimitive.new(min_value)
  end
  
  def visit_mean(mean, runtime)
    start_cell = mean.left.traverse(self, runtime)
    end_cell = mean.right.traverse(self, runtime)
  
    start_row, start_col = start_cell.left.value, start_cell.right.value
    end_row, end_col = end_cell.left.value, end_cell.right.value
  
    values = []
  
    for row in start_row..end_row
      for col in start_col..end_col
        cell_value = runtime.get_cell_value(row, col)
        if cell_value.is_a?(IntegerPrimitive) || cell_value.is_a?(FloatPrimitive)
          values << cell_value.value
        elsif !cell_value.nil? && cell_value != ""
          # puts "Warning: Non-numeric value encountered in cell [#{row}, #{col}], ignoring in mean calculation"
        end
      end
    end
  
    if values.empty?
      return FloatPrimitive.new(0.0)  # Avoid division by zero
    end
  
    mean_value = values.sum.to_f / values.size
    FloatPrimitive.new(mean_value)
  end
  
  def visit_sum(sum, runtime)
    start_cell = sum.left
    end_cell = sum.right
  
    start_row, start_col = start_cell.left.value, start_cell.right.value
    end_row, end_col = end_cell.left.value, end_cell.right.value
  
    values = []
  
    for row in start_row..end_row
      for col in start_col..end_col
        cell_value = runtime.get_cell_value(row, col)
        if cell_value.is_a?(IntegerPrimitive) || cell_value.is_a?(FloatPrimitive)
          values << cell_value.value
        elsif !cell_value.nil? && cell_value != ""
          # puts "Warning: Non-numeric value encountered in cell [#{row}, #{col}], ignoring in sum calculation"
        end
      end
    end
  
    if values.empty?
      raise "Error: No numeric values found in the given range for sum calculation"
    end
  
    total_sum = values.sum
    total_sum.is_a?(Float) ? FloatPrimitive.new(total_sum) : IntegerPrimitive.new(total_sum)
  end
  
  ## ================================ Logical Operations =====================================

  def visit_and(and_op, runtime)
    left_value = and_op.left.traverse(self, runtime)
    unless left_value.is_a?(BooleanPrimitive)
      raise "Error: Left operand for 'AND' is not a boolean"
    end
  
    if !left_value.value
      return BooleanPrimitive.new(false)
    end
  
    right_value = and_op.right.traverse(self, runtime)
    unless right_value.is_a?(BooleanPrimitive)
      raise "Error: Right operand for 'AND' is not a boolean"
    end
  
    BooleanPrimitive.new(left_value.value && right_value.value)
  end
  
  def visit_or(or_op, runtime)
    left_value = or_op.left.traverse(self, runtime)
    unless left_value.is_a?(BooleanPrimitive)
      raise "Error: Left operand for 'OR' is not a boolean"
    end
  
    if left_value.value
      return BooleanPrimitive.new(true)
    end
  
    right_value = or_op.right.traverse(self, runtime)
    unless right_value.is_a?(BooleanPrimitive)
      raise "Error: Right operand for 'OR' is not a boolean"
    end
  
    BooleanPrimitive.new(left_value.value || right_value.value)
  end
  
  def visit_not(not_op, runtime)
    value = not_op.value.traverse(self, runtime)
  
    unless value.is_a?(BooleanPrimitive)
      raise "Error: Operand for 'NOT' is not a boolean"
    end
  
    BooleanPrimitive.new(!value.value)
  end
  
  ## ================================ R & L Values =====================================
  
  def visit_rvalue(r_value, runtime)
    row = r_value.left.traverse(self, runtime).value
    col = r_value.right.traverse(self, runtime).value
  
    unless row.is_a?(Integer) && col.is_a?(Integer)
      raise "Invalid cell reference: Indices must resolve to integers"
    end
  
    value = runtime.get_cell_value(row, col)
    unless value.is_a?(IntegerPrimitive) || value.is_a?(FloatPrimitive)
      raise "Invalid type at cell [#{row}, #{col}]: #{value.class}"
    end
  
    value
  end
  
  def visit_lvalue(l_value, runtime)
    cell_address = CellAddressPrimitive.new(l_value.left.traverse(self, runtime), l_value.right.traverse(self, runtime))
  
    unless cell_address.left.is_a?(IntegerPrimitive) && cell_address.right.is_a?(IntegerPrimitive)
      raise "Error: Invalid cell address for L-value"
    end
  
    cell_address
  end

  ## ================================ Variables & Flow =====================================
  
  def visit_block(block, runtime)
    for statement in block.statements do
      output = statement.traverse(self, runtime)
    end
    output
  end

  def visit_assignment(assignment, runtime)
    value = assignment.statement.traverse(self, runtime)
    runtime.add(assignment.variable.text, value)
    value
  end

  def visit_reference(variable, runtime)
    if runtime.variables.key?(variable.variable)
      val = runtime.variables[variable.variable]
    else
      p runtime.variables
      raise "Error: Uninitialized variable referenced #{variable.variable}"
    end
    val
  end

  def visit_conditional(conditional, runtime)
    condition_result = conditional.condition.traverse(self, runtime)
  
    unless condition_result.is_a?(BooleanPrimitive)
      raise "Error: Condition must evaluate to a boolean"
    end
  
    if condition_result.value
      conditional.if_block.traverse(self, runtime) if conditional.if_block
    else
      conditional.else_block.traverse(self, runtime) if conditional.else_block
    end
  end

  def visit_for_loop(for_loop, runtime)
    for row in for_loop.start_row.text..for_loop.end_row.text
      for col in for_loop.start_col.text..for_loop.end_col.text
        cell_value = runtime.get_cell_value(Integer(row), Integer(col))

        runtime.add(for_loop.iterator.text, cell_value)
        result = for_loop.body.traverse(self, runtime)
      end
    end
    result
  end
  
end
