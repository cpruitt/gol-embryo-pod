class Cell
  attr_reader :position, :world

  def initialize(x = 0, y = 0)
    @position = Position.new(x, y)
  end
end