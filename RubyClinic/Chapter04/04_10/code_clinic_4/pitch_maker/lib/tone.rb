class Tone
  
  SOUND_FILE = '440Hz_for_5sec.wav'

  def initialize(window)
    @window = window
    file_path = File.expand_path(File.join('sounds', SOUND_FILE))
    @sample = Gosu::Sample.new(window, file_path)
  end
  
  def start
    if @instance
      @instance.resume
    else
      @instance = @sample.play(volume, speed, true)
    end
  end
  
  def stop
    @instance.pause if playing?
  end

  def update
    puts "V: #{volume}, S: #{speed}"
    if playing?
      @instance.volume = volume
      @instance.speed = speed
    end
  end
  
  def playing?
    @instance && @instance.playing?
  end

  def volume
    # volumes should be between 0 and 1
    @window.mouse_x_percent
  end
  
  # increasing speed increases pitch
  def speed
    # speeds should be between 1 and 2
    adjust_playback_speed(1.0 - @window.mouse_y_percent)
  end

  private
  
    # 0.0 = no increase, i.e. regular speed
    # 1.0 = 100% increase, i.e. double speed
    def adjust_playback_speed(percent)
      base_speed = 1.0 # A-440Hz
      top_speed  = 2.0 # A-880Hz
      base_speed + (percent * (top_speed - base_speed))
    end

end
