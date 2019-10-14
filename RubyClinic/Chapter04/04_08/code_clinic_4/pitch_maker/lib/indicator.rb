class Indicator
  
  LEFT  = '<'
  RIGHT = '>'
  UP    = '^'
  DOWN  = 'v'
  STOP  = '.'

  UPDATE_DELAY = 0.4 # seconds

  def initialize(window)
    @window = window
    @cursor = STOP
    @last_x, @last_y = 0, 0
  end
  
  def update
    if updateable?
      refresh_appearance
    end
    @last_x, @last_y = @window.mouse_x, @window.mouse_y
  end
  
  def draw
    x, y = @window.mouse_x, @window.mouse_y
    z_index = 1000
    c = Gosu::Color::RED
    @window.font.draw(@cursor, x, y, z_index, 1.0, 1.0, c)
  end

  private
    
    def refresh_appearance
      x_diff = @window.mouse_x - @last_x
      y_diff = @window.mouse_y - @last_y

      if x_diff.abs > y_diff.abs
        # primarily we are moving horizontally
        @cursor = x_diff < 0 ? LEFT : RIGHT
      elsif y_diff.abs > x_diff.abs
        # primarily we are moving vertically
        @cursor = y_diff < 0 ? UP : DOWN
      else
        # we are stopped
        @cursor = STOP
      end

      @last_update = Time.now
    end

    # Only update when we are stopped, or when a 
    # brief delay has passed. This makes transitions 
    # from movement to stopped smoother.
    def updateable?
      return true if @cursor == STOP
      now = Time.now
      @last_update ||= now
      now - @last_update > UPDATE_DELAY
    end
    
end
