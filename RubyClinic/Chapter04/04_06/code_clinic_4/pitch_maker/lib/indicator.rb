class Indicator
  
  def initialize(window)
    @window = window
    @cursor = 'X'
  end
  
  def update
  end
  
  def draw
    x, y = @window.mouse_x, @window.mouse_y
    z_index = 1000
    c = Gosu::Color::RED
    @window.font.draw(@cursor, x, y, z_index, 1.0, 1.0, c)
  end

end
