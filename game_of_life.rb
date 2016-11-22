require 'bundler/setup'
require 'curses'
require './game'
require './world'
require './cell'
require './embryo'
require './pod'
require './position'
require './pod_seeder'

class GoLPods
  def initialize
    begin
      puts "Choose a seeder to start:"
      seeders = PodSeeder.seeders.keys.sort
      puts "0: Quit / Cancel"
      seeders.each_with_index do |seeder, idx|
        desc = PodSeeder.desc(seeder)
        puts "#{idx + 1}: #{desc}"
      end

      selected_seeder = gets.to_i - 1
      if selected_seeder == -1
        puts "Bye."
        return
      end

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

      # PodSeeder.dev_seed(@game)
      PodSeeder.send(seeders[selected_seeder], @game)

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