class Tone
  
  SOUND_FILE = '440Hz_for_5sec.wav'

  def initialize(window)
    @window = window
    file_path = File.expand_path(File.join('sounds', SOUND_FILE))
    @sample = Gosu::Sample.new(window, file_path)
  end
  
  def start
    @instance = @sample.play(volume, speed, true)
  end
  
  def stop
    @instance.stop if playing?
  end
  
  def playing?
    @instance && @instance.playing?
  end

  def volume
    1
  end
  
  def speed
    1
  end

end
