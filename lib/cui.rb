require 'curses'

class CUI
  def initialize(x, y, width, height)
    @width = width
    @height = height

    Curses.init_screen
    @win = Curses::Window.new @height, @width, 1, 1 
    @win.box ?|, ?-, ?*

    render_title 'ruby_tetris', 'center'
    @subwin = @win.subwin @height - 4, @width - 2, 3, 1

    @win.refresh
    @subwin.refresh
  end

  def render_title(title, align='left')
    x =
      case align
      when 'left'   then 1
      when 'center' then @width / 2 - title.length / 2
      when 'right'  then @width - title.length - 2
      end

    @win.setpos 1, x
    @win.addstr title
    @win.setpos 2, 1
    @win.addstr '-' * (@width - 2)
  end

  def destroy
    @win.getch
    @win.close
    Curses.close_screen
  end

  def render(x, y, str)
    @subwin.setpos y, x
    @subwin.addstr str
  end

  def refresh
    @subwin.refresh
  end

  def clear
    @subwin.clear
  end
end
