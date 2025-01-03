class Grid
  attr_reader :size, :box

  def initialize(size)
    @size = size
    # Why the + 1?
    @box = Array.new(size + 1) { Array.new(size + 1) }
  end

  def setup_grid
    for i in 0..@size
      for j in 0..@size
        @box[i][j] = CellAddressPrimitive.new(i, j)
      end
    end
  end

  def display_box
    for i in 0..@size
      for j in 0..@size
        value = @box[i][j]
        puts "Cell [#{i}][#{j}] = #{value}"
      end
    end
  end

  def update_cell(row, col, value)
    if row.between?(0, @size) && col.between?(0, @size)
      @box[row][col] = value
    else
      puts "Error: Cell [#{row}][#{col}] is out of bounds"
    end
  end


  def return_box
    str = ""
    for i in 0..@size
      for j in 0..@size
        value = @box[i][j]
        str << "Cell [#{i}][#{j}] = #{value.is_a?(CellAddressPrimitive) ? value.to_s : value}\n"
      end
    end
    str
  end
  
end