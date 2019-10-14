class Queen

  @@string = 'Q'

  attr_accessor :column, :row
  
  def to_s
    @@string
  end
  
  def location
    [column, row]
  end
  
  def location?(x,y)
    location == [x,y]
  end
  
end
