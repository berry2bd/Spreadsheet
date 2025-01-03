class Token
  attr_reader :type, :text, :start_index, :end_index

  def initialize(type, text, start_index, end_index)
    @type = type               # type of the token (identifier, keyword, operator)
    @text = text               # source text of the token
    @start_index = start_index # starting index of the token in the source code
    @end_index = end_index     # ending index of the token in the source code
  end

  def to_s
    "#{type}    #{text}, [#{start_index}, #{end_index}]"
  end

end
