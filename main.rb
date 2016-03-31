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

  SHAPES[1] = [[0, 0, 0, 0],
               [1, 1, 1, 1],
               [0, 0, 0, 0],
               [0, 0, 0, 0]]

  SHAPES[2] = [[0, 0, 0, 0],
               [1, 1, 1, 0],
               [1, 0, 0, 0],
               [0, 0, 0, 0]]
  
  SHAPES[3] = [[0, 0, 0, 0],
               [1, 1, 1, 0],
               [0, 0, 1, 0],
               [0, 0, 0, 0]]

  SHAPES[4] = [[0, 0, 0, 0],
               [1, 1, 0, 0],
               [0, 1, 1, 0],
               [0, 0, 0, 0]]

  SHAPES[5] = [[0, 0, 0, 0],
               [0, 1, 1, 0],
               [1, 1, 0, 0],
               [0, 0, 0, 0]]
  
  SHAPES[6] = [[0, 0, 0, 0],
               [0, 1, 0, 0],
               [1, 1, 1, 0],
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

    @cur_y = @cur_x = 0

    @lose_flag = false

    # user interface
    Curses.init_screen
    Curses.raw
    Curses.noecho
    @frame = Curses::Window.new STAGE_H+2, STAGE_W+2, 0, 0
    @frame.box ?|, ?-, ?*
    @frame.refresh

    @win = @frame.subwin STAGE_H, STAGE_W, 1, 1
    # @win.timeout=0.1
  end

  # create a new shape
  def create_shape
    id = rand 7
    @cur_y = 0
    @cur_x = 5
    @shape = SHAPES[id].dup
  end

  def rotate_shape(shape=@shape)
    ret = []
    4.times {ret.push Array.new 4, 0}

    4.times do |i|
      4.times do |j|
        ret[i][j] = shape[3-j][i]
      end
    end
    ret
  end

  def render
    # overlay buffer
    buf = []
    STAGE_H.times do |y|
      buf.push @stage[y].dup
    end
    4.times do |i|
      4.times do |j|
        buf[@cur_y+i][@cur_x+j] = @shape[i][j] if @shape[i][j] != 0
      end
    end

    # render
    @win.clear
    buf.each_with_index do |a, y|
      @win.setpos y, 0
      @win.addstr a.map { |x| CH[x] }.join
    end
    @win.refresh
  end

  def valid(offset_y0, offset_x0, shape=@shape)
    offset_y1 = offset_y0 + @cur_y
    offset_x1 = offset_x0 + @cur_x
    
    ret = true
    4.times do |i|
      4.times do |j|
        if shape[i][j] != 0
          if offset_y1 + i >= STAGE_H \
            || offset_x1 + j >= STAGE_W \
            || offset_x1 + j < 0 \
            || @stage[offset_y1+i][offset_x1+j] != 0
            ret = false
          end
        end
      end
    end
    ret
  end

  def freeze_shape
    4.times do |i|
      4.times do |j|
        @stage[@cur_y+i][@cur_x+j] = @shape[i][j] if @shape[i][j] == 1
      end
    end
  end

  def clear_lines
    STAGE_H.times do |y|
      if @stage[y].inject(0) {|sum, i| sum + i} == STAGE_W
        @stage[y].fill(0)
        y.downto(1) do |yy|
          @stage[yy] = @stage[yy - 1]
        end
      end
    end
  end

  def detect_key
    ch = @win.getch
    case ch
    when 'a' then @cur_x -= 1 if valid 0, -1
    when 'd' then @cur_x += 1 if valid 0, 1
    when 's' then @cur_y += 1 if valid 1, 0
    when 'w' then
      rotated = rotate_shape
      @shape = rotated if valid 0, 0, rotated
    when 'k' then @lose_flag = true
    end
  end

  def start
    ctrl_thread = Thread.new do
      while !@lose_flag
        detect_key
      end
    end

    render_thread = Thread.new do
      while !@lose_flag
        exec_each_sec(0.1) do
          render
        end
      end
    end

    create_shape
    while true do
      exec_each_sec(1) do
        if valid 1, 0
          @cur_y += 1
        else
          freeze_shape
          clear_lines
          create_shape
        end
      end
      break if @lose_flag
    end

    Thread::kill ctrl_thread
    Thread::kill render_thread

    Curses::close_screen
    p @fuck
    p Curses::KEY_LEFT
  end
end

game = Game.new
game.start
