require File.dirname(__FILE__) + '/../game.rb'

describe "Game of Life" do
  
  describe "Game" do
    
    before(:each) do
      @game = GameOfLife.new({
        :window_rows => 30,
        :window_columns => 250
      })
    end
    
    it "Has a line and column count to define a terminal window size" do
      @game.settings[:window_rows].should == 30
      @game.settings[:window_columns].should == 250
    end
    
    it "Will calculate the actual game play area as the window size minus the status bar and seperator row" do
      @game.world.display_settings[:height].should == 27
      @game.world.display_settings[:width].should == 250
    end
    
    it "Can display a status bar" do
      game = GameOfLife.new({
        :window_rows => 30,
        :window_columns => 150
      })
      
      game.new_pods_at([ [2,2],[2,1],[2,3] ])
      game.play 3
      
      expected_status_bar = "======================================================================================================================================================\n" +
                            "Area: 150 X 27      13 North, 75 East   Cycles: 3                                                                                   Arrow keys to move\n" +
                            "Alive: 3            Born: 0             Died: 0                                                                          Space Bar to pause, q to Quit"
      
      game.status_bar.should == expected_status_bar
    end
    
    it "Can calculate a 'display origin' so that the user percieves the origin to be centered in the view instead of in the upper left" do
      game = GameOfLife.new({
        :window_rows => 8,
        :window_columns => 9
      })
      
      game.display_origin.x.should == 4
      game.display_origin.y.should == -2
    end
    
    it "Has a world" do
      @game.world.class.to_s.should == "World"
    end
    
    it "Can add a single pod to the world" do
      @game.new_pod_at(0,0)
      @game.world.pods.count.should == 1
      @game.world.pods.keys.should include("x0y0")
    end
    
    it "Can add a multiple pods to the world" do
      @game.new_pods_at([ [0,0],[1,1],[2,2],[3,3],[4,4] ])
      @game.world.pods.count.should == 5
      @game.world.pods.keys.should include("x0y0")
      @game.world.pods.keys.should include("x1y1")
      @game.world.pods.keys.should include("x2y2")
      @game.world.pods.keys.should include("x3y3")
      @game.world.pods.keys.should include("x4y4")
    end
    
    it "Can set the world's display settings that are not related to window size" do
      game = GameOfLife.new({
        :world_settings => {
          :live_as => "Y",
          :dead_as => "N",
          :origin => Position.new(88,99)
        }
      })
      game.world.display_settings[:live_as].should == "Y"
      game.world.display_settings[:dead_as].should == "N"
      game.world.display_settings[:origin].x.should == 88
      game.world.display_settings[:origin].y.should == 99
    end
    
    it "Can be played for a specified number of cycles" do
      @game.new_pods_at([ [0,0],[0,-1],[0,1] ])
      @game.play(3)
      @game.cycles_played.should == 3
      @game.world.pods.count.should == 3
      @game.world.pods.keys.should include("x0y0")
      @game.world.pods.keys.should include("x1y0")
      @game.world.pods.keys.should include("x-1y0")
    end
    
    it "Can handle the result of each cycle in an arbitrary way" do
      game = GameOfLife.new({
        :window_rows => 8,
        :window_columns => 7,
        :world_settings => {
          :live_as => "#",
          :dead_as => "-",
          :origin => Position.new(0,0)
        }
      })
      
      game.new_pods_at([ [2,2],[2,1],[2,3] ])
      
      play_log = []
      
      game.play 3, do |game|
        play_log << game.world.view_bounds_as_string
      end
      
      even_iteration =  "-------\n" +
                        "--#----\n" +
                        "--#----\n" +
                        "--#----\n" +
                        "-------\n"

      odd_iteration =   "-------\n" +
                        "-------\n" +
                        "-###---\n" +
                        "-------\n" +
                        "-------\n"
      
      
      play_log.count.should == 4
      
      play_log[0].should == even_iteration
      play_log[1].should == odd_iteration
      play_log[2].should == even_iteration
      play_log[3].should == odd_iteration
      
    end
    
  end
  
  describe "World" do
    
    before(:each) do
      @world = World.new
    end
    
    it "Can add a seed at a position creating a cell as an embryo if it does not exist" do
      new_position = Position.new(10,20)
      @world.add_seed_at(new_position)
      @world.embryos.keys.should include("x10y20")
      @world.embryos["x10y20"].world.should equal(@world)
    end
    
    it "Can add a seed at a position without creating an embryo if a Pod already exists" do
      new_position = Position.new(10,20)
      pod = Pod.new(new_position.x, new_position.y)
      @world.add_pod(pod)
      @world.add_seed_at(new_position)
      @world.embryos.keys.should_not include("x10y20")
    end
    
    it "Will fertilize an embryo if adding a seed at a position with an existing embryo" do
      new_position = Position.new(10,20)
      @world.add_seed_at(new_position)
      @world.add_seed_at(new_position)
      @world.embryos.keys.should include("x10y20")
      @world.embryos["x10y20"].seeds.should == 2
    end
    
    it "Will feed a pod if adding a seed at a position with an existing pod" do
      new_position = Position.new(10,20)
      pod = Pod.new(new_position.x, new_position.y)
      @world.add_pod(pod)
      @world.add_seed_at(new_position)
      @world.add_seed_at(new_position)
      @world.pods["x10y20"].food.should == 2
    end
    
    it "Can evolve over cycles with each living pod seeding the surrounding positions once per cycle" do
      @world.add_pod(Pod.new(0,-1))
      @world.add_pod(Pod.new(0,0))
      @world.add_pod(Pod.new(0,1))
      
      @world.evolve
      
      @world.pods.count.should == 3
      @world.pods["x0y-1"].should == nil
      @world.pods["x0y1"].should == nil
      @world.pods["x0y0"].should_not == nil
      @world.pods["x-1y0"].should_not == nil
      @world.pods["x1y0"].should_not == nil
    end
    
    it "Has display settings" do
      settings = @world.display_settings
      
      settings[:origin].x.should == 0
      settings[:origin].y.should == 0
      settings[:width].should == 30
      settings[:height].should == 30
      settings[:live_as].should == "#"
      settings[:dead_as].should == " "
    end
    
    it "Can accept custom display settings" do
      @world.display_settings = {
        :origin => Position.new(10,10),
        :width => 50,
        :height => 50,
        :live_as => "1",
        :dead_as => "0"
      }
      
      settings = @world.display_settings
      
      settings[:origin].x.should == 10
      settings[:origin].y.should == 10
      settings[:width].should == 50
      settings[:height].should == 50
      settings[:live_as].should == "1"
      settings[:dead_as].should == "0"
    end
    
    it "Can report on a subsection of the infinite area as a string/grid" do
      @world.add_pod(Pod.new(-2,-2))
      @world.add_pod(Pod.new(2,-2))
      @world.add_pod(Pod.new(0,0))
      @world.add_pod(Pod.new(-2,2))
      @world.add_pod(Pod.new(2,2))
      
      upper_left = Position.new(-2,-2)
      
      @world.display_settings = {
        :origin => upper_left,
        :width => 5,
        :height => 5,
        :live_as => "1",
        :dead_as => "-"
      }
      
      expected_display =  "1---1\n" +
                          "-----\n" +
                          "--1--\n" +
                          "-----\n" +
                          "1---1\n"
      
      @world.view_bounds_as_string.should == expected_display
    end
    
    it "Can update it's display after each evolution cycle" do
      @world.add_pod(Pod.new(0,-1))
      @world.add_pod(Pod.new(0,0))
      @world.add_pod(Pod.new(0,1))
      
      @world.display_settings = {
        :origin => Position.new(-2,-2),
        :width => 5,
        :height => 5,
        :live_as => "1",
        :dead_as => "-"
      }
      
      iteration_0 = @world.view_bounds_as_string
      iteration_0_expected =  "-----\n" +
                              "--1--\n" +
                              "--1--\n" +
                              "--1--\n" +
                              "-----\n"
      
      @world.evolve
      iteration_1 = @world.view_bounds_as_string
      iteration_1_expected =  "-----\n" +
                              "-----\n" +
                              "-111-\n" +
                              "-----\n" +
                              "-----\n"
      
      @world.evolve
      iteration_2 = @world.view_bounds_as_string
      iteration_2_expected =  "-----\n" +
                              "--1--\n" +
                              "--1--\n" +
                              "--1--\n" +
                              "-----\n"
      
      @world.evolve
      iteration_3 = @world.view_bounds_as_string
      iteration_3_expected =  "-----\n" +
                              "-----\n" +
                              "-111-\n" +
                              "-----\n" +
                              "-----\n"
      
      iteration_0.should == iteration_0_expected
      iteration_1.should == iteration_1_expected
      iteration_2.should == iteration_2_expected
      iteration_3.should == iteration_3_expected
      
    end
    
    it "Can report on statistics for game state as cycles progress" do
      
      @world.add_pod(Pod.new(0,0))
      @world.add_pod(Pod.new(1,0))
      @world.add_pod(Pod.new(0,1))
      @world.add_pod(Pod.new(1,1))
      
      @world.add_pod(Pod.new(2,2))
      @world.add_pod(Pod.new(3,2))
      @world.add_pod(Pod.new(2,3))
      @world.add_pod(Pod.new(3,3))
      
      living_count_0 = @world.statistics[:pods_alive] # 8
      born_count_0 = @world.statistics[:pods_born] # 0
      died_count_0 = @world.statistics[:pods_died] # 0

      @world.evolve
      living_count_1 = @world.statistics[:pods_alive] # 6
      born_count_1 = @world.statistics[:pods_born] # 0
      died_count_1 = @world.statistics[:pods_died] # 2
      
      @world.evolve
      # Skip tracking statistics in this cycle
      # to ensure that stats are updated correctly
      # in every iteration, even when world.statistics
      # is not called
      
      @world.evolve
      living_count_3 = @world.statistics[:pods_alive] # 6
      born_count_3 = @world.statistics[:pods_born] # 0
      died_count_3 = @world.statistics[:pods_died] # 2
      
      cycle_count = @world.statistics[:cycle_count] = 4
      
      cycle_count.should == 4
      
      living_count_0.should == 8
      living_count_1.should == 6
      living_count_3.should == 6
      
      born_count_0.should == 0
      born_count_1.should == 0
      born_count_3.should == 0
      
      died_count_0.should == 0
      died_count_1.should == 2
      died_count_3.should == 2
    end
    
  end
  
  describe "Pod" do
    
    before :each do
      @world = World.new
      @pod = Pod.new(10, 20)
      @pod.world = @world
    end
    
    it "Should have a position" do
      @pod.position.x.should == 10
      @pod.position.y.should == 20
    end
    
    it "Should live in a world" do
      # Set world via cell (in 'before')
      @pod.world.should equal(@world)
      
      # Set world via world
      other_pod = Pod.new(1, 1)
      @world.add_pod(other_pod)
      other_pod.world.should equal(@world)
      
      @world.pods.count.should == 2
      @world.pods.keys.should include("x10y20")
    end
    
    it "Can be fed" do
      pod = Pod.new(1,1)
      pod.gets_fed
      pod.gets_fed
      pod.food.should == 2
    end
    
    it "Can get hungry" do
      pod = Pod.new(1,1)
      pod.gets_fed
      pod.gets_fed
      pod.gets_hungry
      pod.food.should == 0
    end
    
    it "Will use all energy from it's food ant the end of a cycle and in it's end state will be hungry" do
      @world.add_pod(Pod.new(0,-1))
      @world.add_pod(Pod.new(0,0))
      @world.add_pod(Pod.new(0,1))
      
      @world.evolve
      
      @world.pods["x0y0"].food.should == 0
    end
    
    it "Will be fed when fertilized" do
      @pod.fertilize
      @pod.fertilize
      @pod.food.should == 2
    end
    
    it "Can throw seeds in all directions" do
      world = World.new
      pod = Pod.new(0,0)
      
      world.add_pod(pod)
      pod.throw_seeds
      
      world.embryos.count.should == 8
      world.embryos.keys.should include("x-1y-1")
      world.embryos.keys.should include("x0y-1")
      world.embryos.keys.should include("x1y-1")
      world.embryos.keys.should include("x-1y0")
      world.embryos.keys.should include("x1y0")
      world.embryos.keys.should include("x-1y1")
      world.embryos.keys.should include("x0y1")
      world.embryos.keys.should include("x1y1")
    end
    
    it "Will continue to live in the next cycle if it has two units of food" do
      position = @pod.position
      2.times {@pod.fertilize}
      @pod.try_to_survive
      
      @world.pods.count.should == 1
      @world.pods[position.to_s].should equal(@pod)
    end
    
    it "Will continue to live in the next cycle if it has three units of food" do
      position = @pod.position
      3.times {@pod.fertilize}
      @pod.try_to_survive
      
      @world.pods.count.should == 1
      @world.pods[position.to_s].should equal(@pod)
    end
    
    it "Will die of malnourishment in the next cycle if it has fewer than two units of food" do
      position = @pod.position
      1.times {@pod.fertilize}
      @pod.try_to_survive
      
      @world.pods.count.should == 0
      @world.pods[position.to_s].should == nil
      @pod.world.should == nil
    end
    
    it "Will die of overdose in the next cycle if it has more than three units of food" do
      position = @pod.position
      4.times {@pod.fertilize}
      @pod.try_to_survive
      
      @world.pods.count.should == 0
      @world.pods[position.to_s].should == nil
      @pod.world.should == nil
    end
    
  end
  
  describe "Embryo" do
    
    before :each do
      @world = World.new
      @embryo = Embryo.new(10, 20)
      @embryo.world = @world
    end
    
    it "Should have a position" do
      @embryo.position.x.should == 10
      @embryo.position.y.should == 20
    end
    
    it "Should live in a world" do
      # Set world via embryo (in 'before')
      @embryo.world.should equal(@world)
      
      # Set world via world
      other_embryo = Embryo.new(1, 1)
      @world.add_embryo(other_embryo)
      other_embryo.world.should equal(@world)
      
      @world.embryos.count.should == 2
      @world.embryos.keys.should include("x10y20")
    end
    
    it "Should have a seed count" do
      @embryo.seeds.should == 0
    end
    
    it "Can be fertilized" do
      5.times {@embryo.fertilize}
      @embryo.seeds.should == 5
    end
    
    it "Will be born in the next cycle if it has 3 seeds" do
      position = @embryo.position
      3.times {@embryo.fertilize}
      @embryo.try_birth
      
      @world.embryos.count.should == 0
      @world.pods.count.should == 1
      @world.pods[position.to_s].should_not == nil
    end
    
    it "Will die without being born in the next cycle if it has less than 3 seeds" do
      position = @embryo.position
      2.times {@embryo.fertilize}
      @embryo.try_birth
      
      @world.embryos.count.should == 0
      @world.pods.count.should == 0
      @world.pods[position.to_s].should == nil
      @embryo.world.should == nil
    end
    
    it "Will die without being born in the next cycle if it has more than 3 seeds" do
      position = @embryo.position
      4.times {@embryo.fertilize}
      @embryo.try_birth
      
      @world.embryos.count.should == 0
      @world.pods.count.should == 0
      @world.pods[position.to_s].should == nil
    end
    
  end
  
  describe "Position" do
    it "Should remember x and y coordinates" do
      position = Position.new(20,50)
      position.x.should == 20
      position.y.should == 50
    end
    
    it "Should represent coordinates as a unique string" do
      position = Position.new(20,-50)
      position.to_s.should == "x20y-50"
    end
    
    it "Should be able to move to the north, south, east, and west" do
      position_1 = Position.new(10,20)
      position_2 = Position.new(1,2)
      position_1.move.east_by(10).north_by(5)
      position_2.move.west_by(5).south_by(10)
      
      position_1.x.should == 20
      position_1.y.should == 25
      position_2.x.should == -4
      position_2.y.should == -8
    end
    
    it "Should be able to copy itself" do
      position_1 = Position.new(10,20)
      position_2 = position_1.copy.west_by(5).south_by(10)
      
      position_1.x.should == 10
      position_1.y.should == 20
      position_2.x.should == 5
      position_2.y.should == 10
    end
    
    it "Can display is location as a label in terms of North, South, East, West instead of positive / negative values" do
      position_1 = Position.new(10,20)
      position_2 = Position.new(-30,-15)
      position_1.in_compass_terms.should == "20 North, 10 East"
      position_2.in_compass_terms.should == "15 South, 30 West"
    end
  end
  
  
  
end