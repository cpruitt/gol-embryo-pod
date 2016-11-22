class PodSeeder
  def self.desc(key, description = nil)
    @desc ||= {}
    @desc[key] = description if description
    @desc[key]
  end

  def self.seeders
    @desc
  end

  desc :dev_seed, "Dev Seed: The original development seed set for this game (2011)"
  def self.dev_seed(game)
    game.new_pods_at([
      [5,5],
      [5,6],
      [5,4],

      [10,10],
      [10,11],
      [10,12],
      [9,12],
      [8,11],

      [20,10],
      [20,11],
      [20,12],
      [19,12],
      [18,11]
    ])

    (0..100).each do |y|
      game.new_pod_at(0,y)
    end

    (50..75).each do |y|
      (50..75).each do |x|
        game.new_pod_at(x,y)
      end
    end
  end

  desc :random, "Drop a bunch of random seeds"
  def self.random(game)
    settings = game.settings

    width = settings[:window_columns]
    height = settings[:window_rows]

    center_x = width / 2
    center_y = height / 2

    min_x = center_x - (width * 1)
    max_x = center_x + (width * 1)
    min_y = center_y - (height * 1)
    max_y = center_y + (height * 1)

    5000.times do
      x = rand(min_x..max_x)
      y = rand(min_y..max_y)
      game.new_pod_at(x,y) unless game.pod_at(x,y)
    end
  end


end