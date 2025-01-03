require_relative 'evaluator'
require_relative 'BinaryUnary'
require_relative 'grid'
require_relative 'lexer'
require_relative 'parser'
require_relative 'runtime'
require_relative 'serializer'
require 'curses'

# To exit, press q, to enter formula editor and exit formula enter press Enter, to evaluate something use = then expression

class Driver
  attr_reader :rows, :columns

  def initialize(rows, columns)
    @rows = rows
    @columns = columns
    @grid_data = Array.new(rows) { Array.new(columns, "") }
    @cell_formulas = Array.new(rows) { Array.new(columns, "") }
    @error_log = []
    @grid = Grid.new([@rows, @columns].max)
    @runtime = Runtime.new(@grid)
  end

  def main
    
    
    Curses.init_screen
    Curses.cbreak
    Curses.noecho
    Curses.start_color
    Curses.init_pair(1, Curses::COLOR_BLACK, Curses::COLOR_WHITE)
    win = Curses.stdscr
    win.keypad(true)

    # Create windows and initialize some values for later use

    debug_window_width = Curses.cols / 2
    main_window_width = Curses.cols - debug_window_width

    editor_win = Curses::Window.new(3, main_window_width, 0, 0)
    display_win = Curses::Window.new(3, main_window_width, 3, 0)
    grid_win = Curses::Window.new(Curses.lines - 6, main_window_width, 6, 0)
    grid_win.keypad(true)
    debug_win = Curses::Window.new(Curses.lines, debug_window_width, 0, main_window_width)

    row, col = 0, 0
    in_edit_mode = false

   
    begin
      loop do
         # Draw the components of the display
        draw_grid(grid_win, row, col)
        draw_editor(editor_win, in_edit_mode, @cell_formulas[row][col])
        draw_display_panel(display_win, @grid_data[row][col])
        draw_debug_window(debug_win)

        grid_win.refresh
        editor_win.refresh
        display_win.refresh
        debug_win.refresh

        # Get the character the user types
        ch = grid_win.getch

        if in_edit_mode
          # 'enter' has been inputted, return to the spreadsheet
          if ch == 10
            in_edit_mode = false
            if !@cell_formulas[row][col].empty?
              update_cell(@cell_formulas[row][col], row, col, @grid)
            end
            (0...@columns).each do |c|
              (0...@rows).each do |r|
                if !@runtime.get_cell_value(r, c).nil?
                  update_cell(@cell_formulas[r][c], r, c, @grid)
                end
              end
            end
          # update the formula editor based on user input
          else
            handle_edit_mode(editor_win, ch, row, col, @grid)
          end
        else
          case ch
          when Curses::KEY_DOWN
            row += 1 if row < @rows - 1
          when Curses::KEY_UP
            row -= 1 if row > 0
          when Curses::KEY_LEFT
            col -= 1 if col > 0
          when Curses::KEY_RIGHT
            col += 1 if col < @columns - 1
          when 10
            in_edit_mode = true
            editor_win.clear
            draw_editor(editor_win, true, @cell_formulas[row][col])
          when 'q'
            break
          end
        end
      end
    ensure
      Curses.close_screen
    end
  end

  def draw_editor(win, in_edit_mode, text)
    win.clear
    win.setpos(1, 1)
    win.attron(Curses.color_pair(1)) if in_edit_mode
    win.addstr("Formula Editor: #{text}")
    win.attroff(Curses.color_pair(1)) if in_edit_mode
    win.clrtoeol
    win.refresh
  end

  def draw_display_panel(win, content)
    win.clear
    win.setpos(1, 1)
    win.addstr("Display Panel: #{content}")
    win.clrtoeol
    win.refresh
  end

  def draw_grid(win, current_row, current_col)
    column_width = 8
    win.clear
    win.setpos(0, 4)
    (0...@columns).each do |c|
      win.addstr("|#{(c).to_s.rjust(column_width - 1)}")
    end
    win.addstr("|\n")

    (0...@rows).each do |r|
      win.setpos(r + 1, 0)
      win.addstr((r).to_s.rjust(3) + " ")

      (0...@columns).each do |c|
        cell_value = @grid_data[r][c].to_s.center(column_width - 1)
        if r == current_row && c == current_col
          win.attron(Curses.color_pair(1) | Curses::A_BOLD)
          win.addstr("|#{cell_value}")
          win.attroff(Curses.color_pair(1) | Curses::A_BOLD)
        else
          win.addstr("|#{cell_value}")
        end
      end
      win.addstr("|\n")
    end
    win.refresh
  end

  def handle_edit_mode(editor_win, ch, row, col, grid)
    input = @cell_formulas[row][col] || ""
  
    if ch.is_a?(String) && ch.match?(/[[:print:]]/)
      if input == ""
        input = ch
      else
        input << ch
      end
      @cell_formulas[row][col] = input
    elsif ch == 127 || ch == Curses::KEY_BACKSPACE
      input.chop!
      @cell_formulas[row][col] = input
    end
    
    editor_win.clear
    draw_editor(editor_win, true, input)
  end
  
  def update_cell(input, row, col, grid)
    if input.start_with?("=")
      begin
        formula = input[1..-1].strip
        lexer = Lexer.new(formula)
        tokens = lexer.lex
        parser = Parser.new(tokens)
        expression = parser.parse
        evaluator = Evaluator.new(@runtime)
        result = expression.traverse(evaluator, @runtime)
  
        if result.is_a?(IntegerPrimitive) || result.is_a?(FloatPrimitive) || result.is_a?(BooleanPrimitive)
          @grid_data[row][col] = result.value.to_s[0, 5]
          grid.update_cell(row, col, result)
        else
          raise "Unsupported result type: #{result.class}"
        end
      rescue => e
        @grid_data[row][col] = "ERR"
        @error_log << "Cell (#{row}, #{col}): #{e.message}"
      end
    else
      stripped_input = input.strip.downcase
      case stripped_input
      when "true"
        grid.update_cell(row, col, BooleanPrimitive.new(true))
        @grid_data[row][col] = "true"
      when "false"
        grid.update_cell(row, col, BooleanPrimitive.new(false))
        @grid_data[row][col] = "false"
      else
        begin
          numeric_input = Float(input)
          primitive = numeric_input == numeric_input.to_i ? IntegerPrimitive.new(numeric_input.to_i) : FloatPrimitive.new(numeric_input)
          grid.update_cell(row, col, primitive)
          @grid_data[row][col] = input[0, 5]
        rescue
          @grid_data[row][col] = "ERR"
          @error_log << "Cell (#{row}, #{col}): Invalid input '#{input}'"
        end
      end
    end
  end
  
  def draw_debug_window(win)
    win.clear
    win.box("|", "-")
    win.setpos(0, 1)
    win.addstr(" Error/Debug Log ")

    line_count = 1
    @error_log.last(win.maxy - 2).each do |error|
      split_error = error.scan(/.{1,#{win.maxx - 2}}/)
      split_error.each do |line|
        break if line_count >= win.maxy - 1
        win.setpos(line_count, 1)
        win.addstr(line)
        line_count += 1
      end
    end
    win.refresh
  end
end

driver = Driver.new(10, 10)
driver.main
