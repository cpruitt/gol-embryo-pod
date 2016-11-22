require 'bundler/setup'
require 'curses'
require './game'

class GoLPods
  def initialize
    begin
      Curses.noecho
      Curses.init_screen
      Curses.curs_set 0
      Curses.stdscr
      Curses.stdscr.keypad = true
      Curses.stdscr.nodelay = true

      @game = GameOfLife.new({
        :window_rows => Curses.lines,
        :window_columns => Curses.cols
      })

      @game.new_pods_at([
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
        @game.new_pod_at(0,y)
      end

      (50..75).each do |y|
        (50..75).each do |x|
          @game.new_pod_at(x,y)
        end
      end

      play_game
    ensure
      Curses.close_screen
    end

    puts closing_message
  end

  def play_game


    @game.play do |game|
      keypress = Curses.getch
      unless false #keypress == ""
        case keypress
        when Curses::Key::UP then game.world.display_settings[:origin].move.south_by(3)
        when Curses::Key::DOWN then game.world.display_settings[:origin].move.north_by(3)
        when Curses::Key::RIGHT then game.world.display_settings[:origin].move.east_by(3)
        when Curses::Key::LEFT then game.world.display_settings[:origin].move.west_by(3)
        when ?q
          break
        when " "
          if @game.paused?
            @game.resume
          else
            @game.pause
          end
        else
          # do nothing...
        end
      end

      game_content = game.world.view_bounds_as_string + game.status_bar
      Curses.clear
      Curses.setpos 0,0
      Curses.addstr game_content.gsub("\n", "")
      Curses.refresh
    end


  end

  def closing_message
    <<-eos


      GAME OF LIFE - EMBRYOS & PODS
      Thank you for playing.
      www.github.com/cpruitt/gol-embryo-pod


    eos
  end

  def self.play
    new()
  end
end

GoLPods.play()