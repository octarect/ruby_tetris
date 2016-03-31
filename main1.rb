#!/usr/bin/env ruby
# encoding: utf-8
$LOAD_PATH << 'lib'

require 'curses'
require 'misc'

class Game
  STAGE_H = 20
  STAGE_W = 10

  SHAPES = []
  SHAPES[0] = [[0, 0, 0, 0],
               [0, 1, 1, 0],
               [0, 1, 1, 0],
               [0, 0, 0, 0]]
  E_NON = 0
  E_BLK = 1
  E_WAL = 9
  CH = {}
  CH[E_NON] = ' '
  CH[E_BLK] = '*'
  CH[E_WAL] = '#'

  # initialize
  def initialize
    # clear the stage
    @stage = []
    STAGE_H.times do |y|
      @stage.push Array.new STAGE_W, 0
    end

    # buffer
    # @buf = []
    # STAGE_H.times {|| @buf.push Array.new STAGE_W, 0}
    
    @cur_y = 0

    # graphics
    @win = Curses::Window.new STAGE_H, STAGE_W, 1, 1
    @win.timeout=1
  end

  # create a new shape
  def create_shape
    id = 0
    @shape = SHAPES[id].dup
  end

  def render
    # overlay buffer
    buf = []
    STAGE_H.times do |y|
      buf.push @stage[y].dup
    end
    4.times do |i|
      4.times do |j|
        buf[@cur_y+i][1+j] = @shape[i][j]
      end
    end

    @win.clear
    buf.each_with_index do |a, y|
      @win.setpos y, 0
      @win.addstr a.map { |x| CH[x] }.join
    end
    @win.refresh
  end

  def start
    create_shape
    while true do
      exec_each_sec(1) do
        @cur_y += 1
        render
      end
      break if @win.getch
    end
  end
end

game = Game.new
game.start
