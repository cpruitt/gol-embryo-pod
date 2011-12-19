require './game'

class GameOfLife
  def initialize
    @world = World.new
    
    @world.add_pod(Pod.new(0,-1))
    @world.add_pod(Pod.new(0,0))
    @world.add_pod(Pod.new(0,1))
    
    upper_left = Position.new(-2,-2)
    
    @world.display_settings = {
      :origin => Position.new(-7,-3),
      :width => 15,
      :height => 7,
      :live_as => "1",
      :dead_as => "-"
    }
  end
  
  def run
    while true
      puts "\n"
      puts @world.view_bounds_as_string
      puts "\n"
      @world.evolve
      sleep 1
    end
  end
end

game = GameOfLife.new
game.run