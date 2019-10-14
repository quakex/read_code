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
  
  def playing?
    @instance && @instance.playing?
  end

  def volume
    # volumes should be between 0 and 1
    @window.mouse_x_percent
  end
  
  def speed
    1
  end

end
