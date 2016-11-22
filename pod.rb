class Pod < Cell
  attr_accessor :food

  def initialize(x = 0, y = 0)
    @food = 0
    super(x, y)
  end

  def world=(world)
    @world = world
    world.add_pod(self) unless world.nil?
  end

  def gets_fed
    @food += 1
  end

  def gets_hungry
    @food = 0
  end

  def fertilize
    gets_fed
  end

  def throw_seeds
    @world.add_seed_at(@position.copy.east_by(1))
    @world.add_seed_at(@position.copy.west_by(1))
    @world.add_seed_at(@position.copy.north_by(1))
    @world.add_seed_at(@position.copy.south_by(1))
    @world.add_seed_at(@position.copy.north_by(1).east_by(1))
    @world.add_seed_at(@position.copy.north_by(1).west_by(1))
    @world.add_seed_at(@position.copy.south_by(1).east_by(1))
    @world.add_seed_at(@position.copy.south_by(1).west_by(1))
  end

  def try_to_survive
    unless @food == 2 || @food == 3
      @world.remove_pod(self)
    end
  end

end