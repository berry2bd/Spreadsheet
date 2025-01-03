require_relative 'token'
class Lexer
  def initialize(source)
    @source = source
    @index = 0
    @tokens = []
    @token_so_far = ''
  end

  def has(target)
    # It's worth including a check to make sure the index is valid.
    @source[@index] == target
  end

  def has_alphabetic
    @source[@index] && 'a' <= @source[@index].downcase && @source[@index].downcase <= 'z'
  end

  def has_numeric
    @source[@index] && '0' <= @source[@index] && @source[@index] <= '9'
  end

  def capture
    @token_so_far += @source[@index]
    @index += 1
  end

  def emit_token(type)
    token = Token.new(type, @token_so_far, @index - @token_so_far.length, @index - 1)
    @tokens.push(token)
    @token_so_far = ''
  end

  def lex
    has_dot = false
    while @index < @source.length
      if has('#') && @source[@index + 1] == '['
        capture # capture #
        capture # capture [
        emit_token(:hash_bracket_start)
      elsif has('[')
        capture
        emit_token(:left_square_bracket)
      elsif has(']')
        capture
        emit_token(:right_square_bracket)
      elsif has(',')
        capture
        emit_token(:comma)
      elsif has('(')
        capture
        emit_token(:left_parenthesis)
      elsif has(')')
        capture
        emit_token(:right_parenthesis)
      elsif has('+')
        capture
        emit_token(:plus)
      elsif has('-')
        capture
        if has('>')
          capture
          emit_token(:assignment)
        else
          emit_token(:minus)
        end
      elsif has('*')
        capture
        if has('*')
          capture
          emit_token(:double_asterisk)
        else
          emit_token(:asterisk)
        end
      elsif has('/')
        capture
        emit_token(:slash)
      elsif has('%')
        capture
        emit_token(:percent)
      elsif has('&')
        capture
        if has('&')
          capture
          emit_token(:and)
        else
          emit_token(:ampersand)
        end
      elsif has('|')
        capture
        if has('|')
          capture
          emit_token(:or)
        else
        emit_token(:pipe)
        end
      elsif has('^')
        capture
        emit_token(:caret)
      elsif has('~')
        capture
        emit_token(:tilde)
      elsif has('.') && @source[@index + 1] == '.'
        capture
        capture
        emit_token(:dot_dot)
      elsif has('.')
        capture
        while has_numeric
          capture
        end
        emit_token(:number)      
      elsif has('<')
        capture
        if has('=')
          capture
          emit_token(:less_than_equal)
        elsif has('<')
          capture
          emit_token(:left_shift)
        else
          emit_token(:less_than)
        end
      elsif has('>')
        capture
        if has('=')
          capture
          emit_token(:more_than_equal)
        elsif has('>')
          capture
          emit_token(:right_shift)
        else
          emit_token(:more_than)
        end
      elsif has('=')
        capture
        if has('=')
          capture
          emit_token(:equal_sign)
        end
      elsif has('!')
        capture
        if has('=')
          capture
          emit_token(:not_equal)
        else
          emit_token(:exclamation)
        end
      elsif has("\n")
        capture
        emit_token(:linebreak)
      # Alternate method of recieving newlines for spreadsheet input
      elsif has ("\\")
        capture
        if has("n")
          capture
          emit_token(:linebreak)
        end
      elsif has_alphabetic
        while has_alphabetic || has_numeric
          capture
        end
        case @token_so_far
        when "sum"
          emit_token(:sum)
        when "mean"
          emit_token(:mean)
        when "min"
          emit_token(:min)
        when "max"
          emit_token(:max)
        when "float"
          emit_token(:float)
        when "int"
          emit_token(:int)
        when "true"
          emit_token(:true)
        when "false"
          emit_token(:false)
        when "/n"
          emit_token(:linebreak)
        when "if"
          emit_token(:if)
        when "else"
          emit_token(:else)
        when "end"
          emit_token(:end)
        when "for"
          emit_token(:for)
        when "in"
          emit_token(:in)
        when "each"
          emit_token(:each)
        when "do"
          emit_token(:do)
        else
          emit_token(:identifier)
        end
      elsif has_numeric
        while has_numeric || has('.')
          capture
        end
        while has_numeric || has('.')
          if has('.')
            if has_dot
              break
            end
            has_dot = true
          elsif has_numeric
            has_numeric = true
          end
          capture
        end
        emit_token(:number)
      elsif has(' ')
        @index += 1 
      # Invalid tokens
      else
        emit_token(:invalid)
        @index += 1
      end
    end
    @tokens
  end
end
