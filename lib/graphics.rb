require 'cui'

class Graphics
  # mode(0:curses)
  def initialize(mode=0)
    @engine = CUI.new 1, 1, 60, 40 if mode == 0
    # @engine = SDL.new if mode == 1
  end

  def put_square(x, y)
    @engine.clear
    @engine.render x, y, '1111'
  end

  def refresh
    @engine.refresh
  end
end
