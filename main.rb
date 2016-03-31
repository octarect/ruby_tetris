#!/usr/bin/env ruby
# encoding: utf-8
$LOAD_PATH << 'lib'

# require 'graphics'
require 'curses'

def exec_each_sec(sec)
  yield
  sleep sec
end

class Game
  P0 = {w:40, h:20, x:1, y:1}
  # P1 = {w:38, h:18, x:2, y:2}
  P1 = {w:12, h:21, x:2, y:2}

  E_NON = 0
  E_BLK = 1
  E_WAL = 9
  CH = {}
  CH[E_NON] = ' '
  CH[E_BLK] = '*'
  CH[E_WAL] = '#'

  BLK_O = [[0, 0, 0, 0],
           [0, 1, 1, 0],
           [0, 1, 1, 0],
           [0, 0, 0, 0]]
  
  BLK_T = [[0, 0, 0, 0],
           [1, 1, 1, 0],
           [0, 1, 0, 0],
           [0, 0, 0, 0]]

  BLK_I = [[1, 0, 0, 0],
           [1, 0, 0, 0],
           [1, 0, 0, 0],
           [1, 0, 0, 0]]

  SPEED = 1

  def initialize
    # Curses.crmode
    @win = Curses::Window.new P1[:h], P1[:w], P1[:y], P1[:x]
    @win.timeout=1
    @stg = []
    P1[:h].times do |i| 
      if i == P1[:h].pred
        line = Array.new P1[:w], E_WAL
      else
        line = Array.new P1[:w], 0 
        line[0] = line[P1[:w].pred] = 9
      end
      @stg[i] = line
    end
    @bx = @by = 0
  end

  def start
    @bx = 2
    while true do
      exec_each_sec(SPEED) do
        @by += 1
        make_block
        render
      end
      break if @by >= P1[:h] - 4
      break if @win.getch
    end

    Curses.close_screen
    @stg.each do |a|
      p a.join
    end
    p BLK_O
  end

  def make_block
    0.upto(3) do |i|
      0.upto(3) do |j|
        @stg[@by+i][@bx+j] = BLK_O[i][j]
      end
    end
  end

  def render
    @win.clear
    @stg.each_with_index do |a, y|
      @win.setpos y, 0
      @win.addstr a.map { |x| CH[x] }.join
    end
    @win.refresh
  end
end

# Curses.init_screen
#
# begin
#     s = "Hello World!"
#     win = Curses::Window.new(7, 40, 5, 10)
#     win.box(?|,?-,?*)
#     win.setpos(win.maxy / 2, win.maxx / 2 - (s.length / 2))
#     win.addstr(s)
#     win.refresh
#     win.getch
#     win.close
# ensure
#     Curses.close_screen
# end

game = Game.new
game.start
