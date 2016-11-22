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
    # More readable method used to update statistics
    statistics
  end

  def statistics
    @statistics[:pods_alive] = @pods.count
    @statistics[:pods_born] = @born_last_cycle
    @statistics[:pods_died] = @died_last_cycle
    @statistics[:cycle_count] = @cycle_count
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

    update_statistics
  end

  def pod_at(x,y)
    @pods[Position.xy_to_s(x,y)]
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