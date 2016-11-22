class GameOfLife
  attr_reader :settings, :world, :cycles_played

  STATUS_BAR_HEIGHT = 3
  STATUS_BAR_COLUMN_WIDTH = 20

  def initialize(options = {})
    @settings = {
      :window_rows => 20,
      :window_columns => 50,
      :world_settings => {},
      :cycle_length => 0.1
    }.merge(options)

    @paused = false
    @cycles_played = 0

    @world = World.new
    @world.display_settings = @settings[:world_settings]
    recalculate_world_display_settings
  end

  def resume
    @paused = false
  end

  def pause
    @paused = true
  end

  def paused?
    @paused
  end

  def recalculate_world_display_settings
    @world.display_settings[:width] = @settings[:window_columns]
    @world.display_settings[:height] = @settings[:window_rows] - STATUS_BAR_HEIGHT
  end

  def pod_at(x,y)
    @world.pod_at(x,y)
  end

  def new_pod_at(x,y)
    @world.add_pod(Pod.new(x,y))
  end

  def new_pods_at(pods)
    pods.each { |pod| new_pod_at(pod[0], pod[1]) }
  end

  def play(count = nil)

    yield(self) if block_given?

    # No test for the nil condition.  Not sure how to test "run forever"
    while count.nil? || @cycles_played < count do
      @world.evolve unless paused?

      # There has GOT to be a better way to do this next line
      yield(self) if block_given?

      @cycles_played += 1 unless paused?

      sleep(@settings[:cycle_length])
    end
  end

  def display_origin
    origin = @world.display_settings[:origin].copy
    origin.move.east_by(@world.display_settings[:width] / 2)
    origin.move.south_by(@world.display_settings[:height] / 2)
  end

  def status_bar
    line_1 = ("=" * @settings[:window_columns])
    line_2 = status_bar_line_2
    line_3 = status_bar_line_3
    [line_1, line_2, line_3].join("\n")
  end

  def status_bar_line_2
    line =  format_status_column("Area: #{@world.display_settings[:width]} X #{@world.display_settings[:height]}")
    line += format_status_column("#{display_origin.in_compass_terms}")
    line += format_status_column("Cycles: #{@cycles_played}")
    format_status_line(line, "Arrow keys to move")
  end

  def status_bar_line_3
    stats = @world.statistics
    line =  format_status_column("Alive: #{stats[:pods_alive]}")
    line += format_status_column("Born: #{stats[:pods_born]}")
    line += format_status_column("Died: #{stats[:pods_died]}")
    format_status_line(line, "Space Bar to pause, q to Quit")
  end

  private

    def format_status_column(contents, column_width = STATUS_BAR_COLUMN_WIDTH)
      contents + (" " * (column_width - contents.length))
    end

    def format_status_line(left_side, right_side)
      line = left_side
      line += " " * (@settings[:window_columns] - left_side.length - right_side.length)
      line += right_side
      line
    end

end











