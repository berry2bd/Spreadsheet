class Runtime
  attr_accessor :grid, :variables

  def initialize(grid)
    @grid = grid
    @variables = Hash.new
  end

  def get_cell_value(row, column)
    @grid.box[row][column]
  end

  def add(variable, value)
    @variables.store(variable, value)
  end
end