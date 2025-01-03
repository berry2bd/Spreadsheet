require 'minitest/autorun'
require_relative 'evaluator'
require_relative 'BinaryUnary'
require_relative 'grid'
require_relative 'serializer'
require_relative 'runtime'
require_relative 'parser'

class TestSpreadsheetFunctions < Minitest::Test
  def setup
    @grid = Grid.new(5)
    @runtime = Runtime.new(@grid)
    @evaluator = Evaluator.new(@runtime)
  end

  def test_block
    int1 = IntegerPrimitive.new(10)
    int2 = IntegerPrimitive.new(5)

    add_expr = AdditionOperation.new(int1, int2)
    sub_expr = SubtractionOperation.new(int1, int2)
    mul_expr = MultiplicationOperation.new(int1, int2)
    div_expr = DivisionOperation.new(int1, int2)
    exp_expr = ExponentiationOperation.new(int1, int2)

    statements = [add_expr, sub_expr, mul_expr, div_expr, exp_expr]
    block = Block.new(statements)
    assert_equal 100000, block.traverse(@evaluator, @runtime).value
  end

  def test_lexer_block
    source_code = "3 + 5 \n (2 - 1)"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex

    expected_tokens = ["3", "+", "5", "\n", "(", "2", "-", "1", ")"]
    tokens_text = tokens.map(&:text)
    assert_equal expected_tokens, tokens_text
  end

  def test_parser_block

    source_code = "1 + 2 \n 2 + 3"

    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 5
    assert_equal expected_result, result.value
  end

  def test_assignment
    source_code = "test -> 3"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse
    ast.traverse(@evaluator, @runtime)

    result = @runtime.variables["test"]
    expected_result = 3
    assert_equal expected_result, result.value
  end

  def test_assignment_2
    source_code = "test -> 3 + 2 - 1"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse
    ast.traverse(@evaluator, @runtime)

    result = @runtime.variables["test"]
    expected_result = 4
    assert_equal expected_result, result.value
  end

  def test_reference
    @runtime.add("test", IntegerPrimitive.new(4))
    source_code = "test + 3"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 7
    assert_equal expected_result, result.value

  end

  def test_assignment_with_reference
    @runtime.add("test", IntegerPrimitive.new(4))
    source_code = "test2 -> test + 2 - 1"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse
    ast.traverse(@evaluator, @runtime)

    result = @runtime.variables["test2"]
    expected_result = 5
    assert_equal expected_result, result.value
  end

  def test_simple_conditional
    source_code = "if true \n result -> 10 \n else \n result -> 5 \n end"
  
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse
    ast.traverse(@evaluator, @runtime)
  
    assert_equal 10, @runtime.variables["result"].value
  end

  def test_conditional_with_cell_comparison
    @grid.update_cell(0, 0, IntegerPrimitive.new(2)) # Set cell [0, 0] to 2
    @grid.update_cell(0, 1, IntegerPrimitive.new(1)) # Set cell [0, 1] to 1
  
    source_code = "if #[0, 0] > #[0, 1] \n 1 \n else \n 0 \n end"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse
  
    result = ast.traverse(@evaluator, @runtime)
    expected_result = 1
    assert_equal expected_result, result.value
  end
  
  def test_conditional_without_else
    source_code = "if false \n result -> 10 \n end"
    
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse
    ast.traverse(@evaluator, @runtime)
    

    assert_nil @runtime.variables["result"]
  end
  
  def test_conditional_with_expression
    source_code = "if 5 > 3 \n result -> 15 \n else \n result -> 0 \n end"
    
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse
    ast.traverse(@evaluator, @runtime)
  
    assert_equal 15, @runtime.variables["result"].value
  end
  
  def test_parser_simple_for_loop
    @grid.update_cell(0, 0, IntegerPrimitive.new(1))
    @grid.update_cell(0, 1, IntegerPrimitive.new(2))
    @grid.update_cell(0, 2, IntegerPrimitive.new(2))
    source_code = "count -> 0 \n for value in [0, 0]..[0, 2] do \n count -> count + value \n end"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 5
    assert_equal expected_result, result.value
  end

  def test_for_each_loop_with_conditional
    source = "count -> 0 \n for value in [4, 0]..[4, 3] \n if value > 0 \n count -> count + 1 \n end \n end"

    @grid.update_cell(4, 0, IntegerPrimitive.new(1))
    @grid.update_cell(4, 1, IntegerPrimitive.new(2))
    @grid.update_cell(4, 2, IntegerPrimitive.new(0))
    @grid.update_cell(4, 3, IntegerPrimitive.new(3))
    tokens = Lexer.new(source).lex
    parser = Parser.new(tokens)
    program = parser.parse
    # runtime.add("count", IntegerPrimitive.new(0))

    result = program.traverse(@evaluator, @runtime)
    assert_equal(3, @runtime.variables["count"].value)
  end

  # def test_for_loop_with_arithmetic
  #   source_code = "for i in 1..3 do \n i + 2 \n end"
  #   lexer = Lexer.new(source_code)
  #   tokens = lexer.lex
  #   parser = Parser.new(tokens)
  #   expression = parser.parse
  #   runtime = Runtime.new(Grid.new(10))
  #   evaluator = Evaluator.new(runtime)
  #   result = expression.traverse(evaluator, runtime)
  
  #   assert_equal [3, 4, 5], result.map(&:value)
  # end
  
  # def test_nested_for_loops
  #   source_code = "for i in 1..2 \n for j in 1..2 do \n i * j \n end \n end"
  #   lexer = Lexer.new(source_code)
  #   tokens = lexer.lex
  #   parser = Parser.new(tokens)
  #   expression = parser.parse
  #   runtime = Runtime.new(Grid.new(10))
  #   evaluator = Evaluator.new(runtime)
  #   result = expression.traverse(evaluator, runtime)
  
  #   assert_equal [1, 2, 2, 4], result.map(&:value)
  # end
  
  # def test_for_loop_with_conditional
  #   source_code = "for i in 1..4 do \n if i % 2 == 0 \n i \n else \n 0 \n end \n end"
  #   lexer = Lexer.new(source_code)
  #   tokens = lexer.lex
  #   parser = Parser.new(tokens)
  #   expression = parser.parse
  #   runtime = Runtime.new(Grid.new(10))
  #   evaluator = Evaluator.new(runtime)
  #   result = expression.traverse(evaluator, runtime)
  
  #   assert_equal [0, 2, 0, 4], result.map(&:value)
  # end
  
  # def test_for_loop_with_sum
  #   source_code = "for i in 1..3 do \n sum(i, i * 2) \n end"
  #   lexer = Lexer.new(source_code)
  #   tokens = lexer.lex
  #   parser = Parser.new(tokens)
  #   expression = parser.parse
  #   runtime = Runtime.new(Grid.new(10))
  #   evaluator = Evaluator.new(runtime)
  #   result = expression.traverse(evaluator, runtime)
  
  #   assert_equal [3, 6, 9], result.map(&:value)
  # end
  
  # def test_for_loop_with_grid_update
  #   source_code = "for i in 1..3 do \n #[i, 0] -> i * 2 \n end"
  #   lexer = Lexer.new(source_code)
  #   tokens = lexer.lex
  #   parser = Parser.new(tokens)
  #   expression = parser.parse
  #   grid = Grid.new(10)
  #   runtime = Runtime.new(grid)
  #   evaluator = Evaluator.new(runtime)
  #   expression.traverse(evaluator, runtime)
  
  #   assert_equal 2, grid.box[1][0].value
  #   assert_equal 4, grid.box[2][0].value
  #   assert_equal 6, grid.box[3][0].value
  # end  
  
  def test_primitives
    int_primitive = IntegerPrimitive.new(42)
    float_primitive = FloatPrimitive.new(3.14)
    bool_primitive = BooleanPrimitive.new(true)
    string_primitive = StringPrimitive.new("Hello")

    assert_equal 42, int_primitive.traverse(@evaluator, @runtime).value
    assert_equal 3.14, float_primitive.traverse(@evaluator, @runtime).value
    assert_equal true, bool_primitive.traverse(@evaluator, @runtime).value
    assert_equal "Hello", string_primitive.traverse(@evaluator, @runtime).value
  end

  def test_arithmetic_operations
    int1 = IntegerPrimitive.new(10)
    int2 = IntegerPrimitive.new(5)

    add_expr = AdditionOperation.new(int1, int2)
    sub_expr = SubtractionOperation.new(int1, int2)
    mul_expr = MultiplicationOperation.new(int1, int2)
    div_expr = DivisionOperation.new(int1, int2)
    exp_expr = ExponentiationOperation.new(int1, int2)

    assert_equal 15, add_expr.traverse(@evaluator, @runtime).value
    assert_equal 5, sub_expr.traverse(@evaluator, @runtime).value
    assert_equal 50, mul_expr.traverse(@evaluator, @runtime).value
    assert_equal 2.0, div_expr.traverse(@evaluator, @runtime).value
    assert_equal 100000, exp_expr.traverse(@evaluator, @runtime).value
  end

  def test_relational_operations
    int1 = IntegerPrimitive.new(10)
    int2 = IntegerPrimitive.new(5)

    eq_expr = EqualsOperation.new(int1, int2)
    ne_expr = NotEqualsOperation.new(int1, int2)
    lt_expr = LessThanOperation.new(int1, int2)
    gt_expr = MoreThanOperation.new(int1, int2)

    assert_equal false, eq_expr.traverse(@evaluator, @runtime).value
    assert_equal true, ne_expr.traverse(@evaluator, @runtime).value
    assert_equal false, lt_expr.traverse(@evaluator, @runtime).value
    assert_equal true, gt_expr.traverse(@evaluator, @runtime).value
  end

  def test_bitwise_operations
    int1 = IntegerPrimitive.new(10) # 1010 in binary
    int2 = IntegerPrimitive.new(4)  # 0100 in binary

    and_expr = BitwiseAnd.new(int1, int2)
    or_expr = BitwiseOr.new(int1, int2)
    xor_expr = BitwiseXor.new(int1, int2)

    assert_equal 0, and_expr.traverse(@evaluator, @runtime).value
    assert_equal 14, or_expr.traverse(@evaluator, @runtime).value
    assert_equal 14, xor_expr.traverse(@evaluator, @runtime).value
  end

  def test_logical_operations
    bool1 = BooleanPrimitive.new(true)
    bool2 = BooleanPrimitive.new(false)

    and_expr = AndOperation.new(bool1, bool2)
    or_expr = OrOperation.new(bool1, bool2)
    not_expr = NotOperation.new(bool2)

    assert_equal false, and_expr.traverse(@evaluator, @runtime).value
    assert_equal true, or_expr.traverse(@evaluator, @runtime).value
    assert_equal true, not_expr.traverse(@evaluator, @runtime).value
  end

  def test_casting_operations
    int_primitive = IntegerPrimitive.new(42)
    float_primitive = FloatPrimitive.new(3.14)

    int_to_float = IntToFloat.new(int_primitive)
    float_to_int = FloatToInt.new(float_primitive)

    assert_equal 42.0, int_to_float.traverse(@evaluator, @runtime).value
    assert_equal 3, float_to_int.traverse(@evaluator, @runtime).value
  end

  def test_bitwise_shift_operations
    int1 = IntegerPrimitive.new(8)  # 1000 in binary
    int2 = IntegerPrimitive.new(2)

    left_shift_expr = BitwiseLeftShift.new(int1, int2)
    right_shift_expr = BitwiseRightShift.new(int1, int2)

    assert_equal 32, left_shift_expr.traverse(@evaluator, @runtime).value   # 100000 in binary
    assert_equal 2, right_shift_expr.traverse(@evaluator, @runtime).value   # 0010 in binary
  end

  def test_serialize
    int1 = IntegerPrimitive.new(1)
    int2 = IntegerPrimitive.new(2)
    add = AdditionOperation.new(int1, int2)
    add2 = AdditionOperation.new(int2, add)

    ser = Serializer.new(@runtime)
    assert_equal '(2 + (1 + 2))', ser.visit_addition(add2, @runtime)
  end

  def test_lexer
    source_code = "3 + 5 * (2 - 1)"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex

    expected_tokens = ["3", "+", "5", "*", "(", "2", "-", "1", ")"]
    tokens_text = tokens.map(&:text)
    assert_equal expected_tokens, tokens_text
  end

  def test_add_cells
    @grid.update_cell(1, 1, IntegerPrimitive.new(1))
    @grid.update_cell(2, 2, IntegerPrimitive.new(2))

    source_code = "#[1,1] + #[2,2]"

    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 3
    assert_equal expected_result, result.value
  end

  def test_negative_cells
    @grid.update_cell(0, 0, IntegerPrimitive.new(1))
    @grid.update_cell(1, 1, IntegerPrimitive.new(-2))

    source_code = "#[0,0] + #[1,1]"

    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = -1
    assert_equal expected_result, result.value
  end

  def test_negative_add

    source_code = "-1 + 2"

    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 1
    assert_equal expected_result, result.value
  end

  def test_parser
    source_code = "5 <= 32.0"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse
    refute_nil ast # Ensure AST is returned and valid
  end

  def test_lexing_and
    source_code = "true && true"

    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = true
    assert_equal expected_result, result.value
  end

  def test_mean
    source_code = "1 + mean([0, 0], [2, 1])"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    @grid.update_cell(0, 0, IntegerPrimitive.new(-1)) # Sets cell 0,0 to 1
    @grid.update_cell(1, 1, IntegerPrimitive.new(2)) # Sets cell 1,1 to 2
    @grid.update_cell(2, 1, IntegerPrimitive.new(0.5)) # Sets cell 2,1 to 2

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 1 + ((-1 + 2 + 0.5) / 3.0)
    assert_equal expected_result, result.value
  end

  def test_max
    source_code = "1 + max([0, 0], [2, 1])"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    @grid.update_cell(0, 0, IntegerPrimitive.new(1)) # Sets cell 0,0 to 1
    @grid.update_cell(1, 1, IntegerPrimitive.new(2)) # Sets cell 1,1 to 2
    @grid.update_cell(2, 1, IntegerPrimitive.new(2)) # Sets cell 2,1 to 2

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 1 + 2
    assert_equal expected_result, result.value
  end

  def test_min
    source_code = "1 + min([0, 0], [2, 1])"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    @grid.update_cell(0, 0, IntegerPrimitive.new(1)) # Sets cell 0,0 to 1
    @grid.update_cell(1, 1, IntegerPrimitive.new(2)) # Sets cell 1,1 to 2
    @grid.update_cell(2, 1, IntegerPrimitive.new(2)) # Sets cell 2,1 to 2

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 1 + 1
    assert_equal expected_result, result.value
  end

  def test_equals
    source_code = "1 + 3 == 4 - 2 + 5 - 3"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    @grid.update_cell(0, 0, IntegerPrimitive.new(1)) # Sets cell 0,0 to 1
    @grid.update_cell(1, 1, IntegerPrimitive.new(2)) # Sets cell 1,1 to 2
    @grid.update_cell(2, 1, IntegerPrimitive.new(2)) # Sets cell 2,1 to 2

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 1 + 3 == 4 - 2 + 5 - 3
    assert_equal expected_result, result.value
  end

  def test_exponentiation
    source_code = "(2 ** 3) / 4"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = (2 ** 3) / 4

    assert_equal expected_result, result.value
  end

  def test_milestone1_1
    grid = Grid.new(3)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    mult_expr = MultiplicationOperation.new(IntegerPrimitive.new(7), IntegerPrimitive.new(4))
    add_expr = AdditionOperation.new(mult_expr, IntegerPrimitive.new(3))
    mod_expr = ModuloOperation.new(add_expr, IntegerPrimitive.new(12))

    result = mod_expr.traverse(evaluator, runtime).value
    expected_result = (7 * 4 + 3) % 12

    assert_equal expected_result, result
    assert_equal "(((7 * 4) + 3) % 12)", ser.visit_modulo(mod_expr, runtime)
  end

  def test_milestone1_2
    grid = Grid.new(3)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    grid.update_cell(1, 1, IntegerPrimitive.new(5))  # Set cell [1][1] to 5
    grid.update_cell(2, 1, IntegerPrimitive.new(3))  # Set cell [2][1] to 3

    cell1 = RValue.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1))
    cell2 = RValue.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1))

    neg_cell2 = NegationOperation.new(cell2)
    mult_expr = MultiplicationOperation.new(cell1, neg_cell2)

    result = mult_expr.traverse(evaluator, runtime).value
    expected_result = 5 * -3

    assert_equal expected_result, result
    assert_equal "(#[1, 1] * -#[2, 1])", ser.visit_multiplication(mult_expr, runtime)
  end

  def test_milestone1_3
    grid = Grid.new(4)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    grid.update_cell(2, 4, IntegerPrimitive.new(1))  # Set cell [2][4] to 1

    int1 = IntegerPrimitive.new(1)
    int2 = IntegerPrimitive.new(1)
    int3 = IntegerPrimitive.new(4)
    int4 = IntegerPrimitive.new(3)

    add_expr = AdditionOperation.new(int1, int2)
    cell1 = RValue.new(add_expr, int3)

    shift_expr = BitwiseLeftShift.new(cell1, int4)

    result = shift_expr.traverse(evaluator, runtime).value
    expected_result = 1 << 3

    assert_equal expected_result, result
    assert_equal "(#[(1 + 1), 4] << 3)", ser.visit_bitwise_leftshift(shift_expr, runtime)
  end

  def test_milestone1_4
    grid = Grid.new(4)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    grid.update_cell(0, 0, IntegerPrimitive.new(1))  # Set cell [0][0] to 1
    grid.update_cell(0, 1, IntegerPrimitive.new(2))  # Set cell [0][1] to 2

    cell1 = RValue.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0))
    cell2 = RValue.new(IntegerPrimitive.new(0), IntegerPrimitive.new(1))

    logical_expr = LessThanOperation.new(cell1, cell2)

    result = logical_expr.traverse(evaluator, runtime).value
    expected_result = 1 < 2

    assert_equal expected_result, result
    assert_equal "(#[0, 0] < #[0, 1])", ser.visit_lessthan(logical_expr, runtime)
  end

  def test_milestone1_5
    grid = Grid.new(4)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    float1 = FloatPrimitive.new(3.3)
    float2 = FloatPrimitive.new(3.2)

    comparison_expr = MoreThanOperation.new(float1, float2)
    logical_expr = NotOperation.new(comparison_expr)

    result = logical_expr.traverse(evaluator, runtime).value
    expected_result = !(3.3 > 3.2)

    assert_equal expected_result, result
    assert_equal "!((3.3 > 3.2))", ser.visit_not(logical_expr, runtime)
  end

  def test_milestone1_6
    grid = Grid.new(5)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    grid.update_cell(1, 2, IntegerPrimitive.new(3))
    grid.update_cell(5, 3, IntegerPrimitive.new(2))

    cell_addr1 = CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2))
    cell_addr2 = CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3))

    sum_expr = SumOperation.new(cell_addr1, cell_addr2)

    result = sum_expr.traverse(evaluator, runtime).value
    expected_result = 3 + 2

    assert_equal expected_result, result
    assert_equal "sum([1, 2], [5, 3])", ser.visit_sum(sum_expr, runtime)
  end

  def test_milestone1_7
    grid = Grid.new(5)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    grid.update_cell(1, 2, IntegerPrimitive.new(3))
    grid.update_cell(5, 3, IntegerPrimitive.new(2))
    grid.update_cell(4, 2, IntegerPrimitive.new(2))
    grid.update_cell(4, 3, IntegerPrimitive.new(8))

    cell_addr1 = CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2))
    cell_addr2 = CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3))

    mean_expr = MeanOperation.new(cell_addr1, cell_addr2)

    result = mean_expr.traverse(evaluator, runtime).value
    expected_result = (3 + 2 + 2 + 8) / 4.0

    assert_equal expected_result, result
    assert_equal "mean([1, 2], [5, 3])", ser.visit_mean(mean_expr, runtime)
  end

  def test_milestone1_8
    grid = Grid.new(5)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    grid.update_cell(1, 2, IntegerPrimitive.new(3))
    grid.update_cell(5, 3, IntegerPrimitive.new(2))
    grid.update_cell(4, 2, IntegerPrimitive.new(2))
    grid.update_cell(4, 3, IntegerPrimitive.new(8))

    cell_addr1 = CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2))
    cell_addr2 = CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3))

    min_expr = MinOperation.new(cell_addr1, cell_addr2)

    result = min_expr.traverse(evaluator, runtime).value
    expected_result = 2

    assert_equal expected_result, result
    assert_equal "min([1, 2], [5, 3])", ser.visit_min(min_expr, runtime)
  end

  def test_milestone1_9
    grid = Grid.new(5)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    grid.update_cell(1, 2, IntegerPrimitive.new(3))
    grid.update_cell(5, 3, IntegerPrimitive.new(2))
    grid.update_cell(4, 2, IntegerPrimitive.new(2))
    grid.update_cell(4, 3, IntegerPrimitive.new(8))

    cell_addr1 = CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2))
    cell_addr2 = CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3))

    max_expr = MaxOperation.new(cell_addr1, cell_addr2)

    result = max_expr.traverse(evaluator, runtime).value
    expected_result = 8

    assert_equal expected_result, result
    assert_equal "max([1, 2], [5, 3])", ser.visit_max(max_expr, runtime)
  end

  def test_milestone1_10
    grid = Grid.new(3)
    runtime = Runtime.new(grid)
    evaluator = Evaluator.new(runtime)
    ser = Serializer.new(runtime)

    int1 = IntegerPrimitive.new(7)
    int2 = IntegerPrimitive.new(2)
    float1 = IntToFloat.new(int1)
    division_expr = DivisionOperation.new(float1, int2)

    result = division_expr.traverse(evaluator, runtime).value
    expected_result = 3.5

    assert_equal expected_result, result
    assert_equal "(float(7) / 2)", ser.visit_division(division_expr, runtime)
  end

  #=============================Milestone 2===================================

  def test_milestone2_1
    source_code = "(5 + 2) * 3 % 4"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = (5 + 2) * 3 % 4

    assert_equal expected_result, result.value
  end

  def test_milestone2_2
    source_code = "#[0, 0] + 3"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    @grid.update_cell(0, 0, IntegerPrimitive.new(1))

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 1 + 3

    assert_equal expected_result, result.value
  end

  def test_milestone2_3
    source_code = "#[1 - 1, 0] < #[1 * 1, 1]"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    @grid.update_cell(0, 0, IntegerPrimitive.new(1))
    @grid.update_cell(1, 1, IntegerPrimitive.new(2))

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 1 < 2

    assert_equal expected_result, result.value
  end

  def test_milestone2_4
    source_code = "(5 > 3) && !(2 > 8)"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = (5 > 3) && !(2 > 8)

    assert_equal expected_result, result.value
  end

  def test_milestone2_5
    source_code = "1 + sum([0, 0], [2, 1])"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    @grid.update_cell(0, 0, IntegerPrimitive.new(1))
    @grid.update_cell(1, 1, IntegerPrimitive.new(2))
    @grid.update_cell(2, 1, IntegerPrimitive.new(2))

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 1 + (1 + 2 + 2)

    assert_equal expected_result, result.value
  end

  def test_milestone2_6
    source_code = "float(10) / 4.0"
    lexer = Lexer.new(source_code)
    tokens = lexer.lex
    parser = Parser.new(tokens)
    ast = parser.parse

    result = ast.traverse(@evaluator, @runtime)
    expected_result = 10.to_f / 4.0

    assert_equal expected_result, result.value
  end

    # def test_milestone2_7
  #   #$ is not a valid token
  #   source_code = "$ (5 < 3) && !(2 > 8)"
  #   lexer = Lexer.new(source_code)
  #   tokens = lexer.lex
  #   parser = Parser.new(tokens)
  #   ast = parser.parse

  #   result = ast.traverse(@evaluator, @runtime)
  #   expected_result = (5 > 3) && !(2 > 8)

  #   assert_equal expected_result, result.value
  # end
end