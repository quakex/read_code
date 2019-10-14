require 'gosu'

require_relative('indicator')
require_relative('tone')

class PitchMaker < Gosu::Window
  
  WINDOW_WIDTH = 1280
  WINDOW_HEIGHT = 960
  TITLE = 'Pitch Maker'
  
  attr_reader :font
  
  def initialize
    puts "Launching #{TITLE}"
    super(WINDOW_WIDTH,WINDOW_HEIGHT,false)
    self.caption = TITLE
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @indicator = Indicator.new(self)
    @tone = Tone.new(self)
  end
  
  def update
    @indicator.update
  end
  
  def draw
    draw_background
    display_instructions
    @indicator.draw
  end
  
  def button_down(id)
    case id
    when Gosu::KbEscape, Gosu::KbQ
      puts "Exiting #{TITLE}"
      close
    when Gosu::MsLeft, Gosu::MsRight
      puts "Mouse button down"
    end
  end
  
  def button_up(id)
    case id
    when Gosu::MsLeft, Gosu::MsRight
      puts "Mouse button up"
    end
  end
  
  private
  
    def draw_background
      c = Gosu::Color::BLACK
      z_index = -100
      draw_quad(0, 0, c, width, 0, c,
                0, height, c, width, height, c, 
                z_index )
    end
    
    def display_instructions
      c = Gosu::Color::CYAN
      top_margin = 10
      left_margin = 10
      line_height = 20
      z_index = 200
      [
        "Click mouse to play tone",
        "Move mouse to change pitch/volume", 
        "Press 'q' to exit"
      ].each_with_index do |text, i|
        text_y = top_margin + (i*line_height)
        @font.draw(text, left_margin, text_y, z_index+i, 1.0, 1.0, c)
      end
    end
    
end
