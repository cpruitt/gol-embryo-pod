require File.dirname(__FILE__) + '/../game.rb'

describe "Game of Life" do
  
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
  end
  
  
  
end