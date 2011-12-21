class World
  attr_reader :pods, :embryos, :display_settings
  
  def initialize
    @pods = {}
    @embryos = {}
    @display_settings = {
      :origin => Position.new(0,0),
      :width => 30,
      :height => 30,
      :live_as => "#",
      :dead_as => " "
    }
    
    @cycle_count = 0
    @died_last_cycle = 0
    @born_last_cycle = 0
    
    @statistics = {
      :pods_alive => 0,
      :pods_born => 0,
      :pods_died => 0,
      :cycle_count => 0
    }
  end
  
  def update_statistics
  end
  
  def statistics
    @statistics = {
      :pods_alive => @pods.count,
      :pods_born => @born_last_cycle,
      :pods_died => @died_last_cycle,
      :cycle_count => @cycle_count
    }
    @statistics
  end
  
  def evolve
    @pods.each { |pod_key, pod| pod.throw_seeds }
    @pods.each { |pod_key, pod| pod.try_to_survive }
    @pods.each { |pod_key, pod| pod.gets_hungry }
    @embryos.each { |embryo_key, embryo| embryo.try_birth }
    @cycle_count += 1
    @died_last_cycle = @pods.count < @statistics[:pods_alive] ? @statistics[:pods_alive] - @pods.count : 0
    @born_last_cycle = @pods.count > @statistics[:pods_alive] ? @pods.count - @statistics[:pods_alive] : 0
  end
  
  def add_pod(pod)
    pod.world = self unless pod.world.equal? self
    @pods[pod.position.to_s] = pod
  end
  
  def remove_pod(pod)
    pod.world = nil
    @pods.delete(pod.position.to_s)
  end
  
  def add_embryo(embryo)
    embryo.world = self unless embryo.world.equal? self
    embryos[embryo.position.to_s] = embryo
  end
  
  def remove_embryo(embryo)
    embryo.world = nil
    @embryos.delete(embryo.position.to_s)
  end
  
  def add_seed_at(position)
    if @pods[position.to_s].nil?
      if @embryos[position.to_s].nil?
        embryo = Embryo.new(position.x, position.y)
        embryo.fertilize
        add_embryo(embryo)
      else
        @embryos[position.to_s].fertilize
      end
    else
      @pods[position.to_s].fertilize
    end
  end
  
  def display_settings=(options)
    @display_settings.merge!(options)
  end
  
  def view_bounds_as_string
    result =  ""
    @display_settings[:height].times do |row|
      cursor = Position.new(@display_settings[:origin].x, (@display_settings[:origin].y + row))
      @display_settings[:width].times do
        result += @pods[cursor.to_s].nil? ? @display_settings[:dead_as] : @display_settings[:live_as]
        cursor.move.east_by(1)
      end
      result += "\n"
    end
    result
  end
  
end

class Cell
  attr_reader :position, :world
  
  def initialize(x = 0, y = 0)
    @position = Position.new(x, y)
  end
end

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

class Position
  attr_accessor :x, :y
  
  def initialize(x = 0, y = 0)
    @x, @y = x, y
  end
  
  def to_s
    "x#{@x.to_s}y#{@y.to_s}"
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
end

