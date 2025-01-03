class Serializer
  attr_accessor :grid

  def initialize(grid)
    @grid = grid
  end

  ## ================================ Primitives =====================================
  def visit_integerprimitive(int, runtime)
    int.value.to_s
  end

  def visit_floatprimitive(float, runtime)
    float.value.to_s
  end

  def visit_booleanprimitive(boolean, runtime)
    boolean.value.to_s
  end

  def visit_stringprimitive(string, runtime)
    "\"#{string.value}\""
  end  

  def visit_celladdressprimitive(addr, runtime)
    "[#{addr.left.value}, #{addr.right.value}]"
  end

  ## ================================ Binary Operations =====================================
  def visit_addition(addition, runtime)
    left_value = addition.left.traverse(self, runtime)
    right_value = addition.right.traverse(self, runtime)
    "(#{left_value} + #{right_value})"
  end

  def visit_subtraction(subtraction, runtime)
    left_value = subtraction.left.traverse(self, runtime)
    right_value = subtraction.right.traverse(self, runtime)
    "(#{left_value} - #{right_value})"
  end 

  def visit_multiplication(multiplication, runtime)
    left_value = multiplication.left.traverse(self, runtime)
    right_value = multiplication.right.traverse(self, runtime)
    "(#{left_value} * #{right_value})"
  end

  def visit_division(division, runtime)
    left_value = division.left.traverse(self, runtime)
    right_value = division.right.traverse(self, runtime)
    "(#{left_value} / #{right_value})"
  end

  def visit_modulo(modulo, runtime)
    left_value = modulo.left.traverse(self, runtime)
    right_value = modulo.right.traverse(self, runtime)
    "(#{left_value} % #{right_value})"
  end

  def visit_exponentiation(exp, runtime)
    left_value = exp.left.traverse(self, runtime)
    right_value = exp.right.traverse(self, runtime)
    "(#{left_value} ** #{right_value})"
  end

  def visit_bitwise_and(bitwise_and, runtime)
    left_value = bitwise_and.left.traverse(self, runtime)
    right_value = bitwise_and.right.traverse(self, runtime)
    "(#{left_value} & #{right_value})"
  end

  def visit_bitwise_or(bitwise_or, runtime)
    left_value = bitwise_or.left.traverse(self, runtime)
    right_value = bitwise_or.right.traverse(self, runtime)
    "(#{left_value} | #{right_value})"
  end

  def visit_bitwise_xor(xor, runtime)
    left_value = xor.left.traverse(self, runtime)
    right_value = xor.right.traverse(self, runtime)
    "(#{left_value} ^ #{right_value})"
  end

  def visit_bitwise_leftshift(left_shift, runtime)
    left_value = left_shift.left.traverse(self, runtime)
    right_value = left_shift.right.traverse(self, runtime)
    "(#{left_value} << #{right_value})"
  end

  def visit_bitwise_rightshift(right_shift, runtime)
    left_value = right_shift.left.traverse(self, runtime)
    right_value = right_shift.right.traverse(self, runtime)
    "(#{left_value} >> #{right_value})"
  end

  def visit_and(logical_and, runtime)
    left_value = logical_and.left.traverse(self, runtime)
    right_value = logical_and.right.traverse(self, runtime)
    "(#{left_value} && #{right_value})"
  end

  def visit_or(logical_or, runtime)
    left_value = logical_or.left.traverse(self, runtime)
    right_value = logical_or.right.traverse(self, runtime)
    "(#{left_value} || #{right_value})"
  end

  def visit_equals(equals, runtime)
    left_value = equals.left.traverse(self, runtime)
    right_value = equals.right.traverse(self, runtime)
    "(#{left_value} == #{right_value})"
  end

  def visit_notequals(notequals, runtime)
    left_value = notequals.left.traverse(self, runtime)
    right_value = notequals.right.traverse(self, runtime)
    "(#{left_value} != #{right_value})"
  end
  
  def visit_lessthan(lessthan, runtime)
    left_value = lessthan.left.traverse(self, runtime)
    right_value = lessthan.right.traverse(self, runtime)
    "(#{left_value} < #{right_value})"
  end

  def visit_lessthanequals(lessthanequals, runtime)
    left_value = lessthanequals.left.traverse(self, runtime)
    right_value = lessthanequals.right.traverse(self, runtime)
    "(#{left_value} <= #{right_value})"
  end

  def visit_morethan(morethan, runtime)
    left_value = morethan.left.traverse(self, runtime)
    right_value = morethan.right.traverse(self, runtime)
    "(#{left_value} > #{right_value})"
  end

  def visit_morethanequals(morethanequals, runtime)
    left_value = morethanequals.left.traverse(self, runtime)
    right_value = morethanequals.right.traverse(self, runtime)
    "(#{left_value} >= #{right_value})"
  end

  def visit_rvalue(rvalue, runtime)
    row = rvalue.left.traverse(self, runtime)
    col = rvalue.right.traverse(self, runtime)
    "#[#{row}, #{col}]"
  end

  def visit_lvalue(lvalue, runtime)
    row = lvalue.left.traverse(self, runtime)
    col = lvalue.right.traverse(self, runtime)
    "[#{row}, #{col}]"
  end

  ## ================================ Unary Operations =====================================
  def visit_negation(negation, runtime)
    "-#{negation.value.traverse(self, runtime)}"
  end

  def visit_bitwise_not(bitwise_not, runtime)
    "(~#{bitwise_not.value.traverse(self, runtime)})"
  end

  def visit_floattoint(float_to_int, runtime)
    "int(#{float_to_int.value.traverse(self, runtime)})"
  end

  def visit_inttofloat(int_to_float, runtime)
    "float(#{int_to_float.value.traverse(self, runtime)})"
  end

  def visit_not(logical_not, runtime)
    "!(#{logical_not.value.traverse(self, runtime)})"
  end

  ## ================================ Statistical Operations =====================================
  def visit_mean(mean, runtime)
    start_value = mean.left.traverse(self, runtime)
    end_value = mean.right.traverse(self, runtime)
    "mean(#{start_value}, #{end_value})"
  end

  def visit_sum(sum, runtime)
    start_value = sum.left.traverse(self, runtime)
    end_value = sum.right.traverse(self, runtime)
    "sum(#{start_value}, #{end_value})"
  end

  def visit_min(min, runtime)
    start_value = min.left.traverse(self, runtime)
    end_value = min.right.traverse(self, runtime)
    "min(#{start_value}, #{end_value})"
  end

  def visit_max(max, runtime)
    start_value = max.left.traverse(self, runtime)
    end_value = max.right.traverse(self, runtime)
    "max(#{start_value}, #{end_value})"
  end
end
