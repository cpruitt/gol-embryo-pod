class Position
  attr_accessor :x, :y

  def initialize(x = 0, y = 0)
    @x, @y = x, y
  end

  def self.xy_to_s(x,y)
    # raise "x#{x.to_s}y#{y.to_s}"
    "x#{x.to_s}y#{y.to_s}"
  end

  def to_s
    self.class.xy_to_s(@x,@y)
    # "x#{@x.to_s}y#{@y.to_s}"
  end

  def move
    # this is just convenience to make using the object more readable
    self
  end

  def copy
    Position.new(@x, @y)
  end

  def east_by(distance = 0)
    @x += distance
    self
  end

  def west_by(distance = 0)
    east_by(0-distance)
  end

  def north_by(distance = 0)
    @y += distance
    self
  end

  def south_by(distance = 0)
    north_by(0-distance)
  end

  def in_compass_terms
    direction_x = x > 0 ? "East" : "West"
    value_x = x.abs
    direction_y = x > 0 ? "North" : "South"
    value_y = y.abs
    "#{value_y} #{direction_y}, #{value_x} #{direction_x}"
  end

end