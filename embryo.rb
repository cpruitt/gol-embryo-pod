class Embryo < Cell
  attr_reader :seeds

  def initialize(x = 0, y = 0)
    @seeds = 0
    super(x, y)
  end

  def world=(world)
    @world = world
    world.add_embryo(self) unless world.nil?
  end

  def fertilize
    @seeds += 1
  end

  def try_birth
    if @seeds == 3
      pod = Pod.new(@position.x, @position.y)
      @world.add_pod(pod)
    end
    @world.remove_embryo(self)
  end
end